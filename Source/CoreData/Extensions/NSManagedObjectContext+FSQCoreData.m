//
//  NSManagedObjectContext+FSQCoreData.m
//  FivesquareKit
//
//  Created by John Clayton on 4/18/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "NSManagedObjectContext+FSQCoreData.h"

#import "FSQAsserter.h"
#import "FSQLogging.h"

#import "NSManagedObject+FSQCoreData.h"


static NSString *kNSManagedObjectContext_FSQErrorDomain = @"NSManagedObjectContext (FSQCoreData)";

#define kFSQCoreDataInvalidDefaultData 1


@implementation NSManagedObjectContext (FSQCoreData)


// ========================================================================== //

#pragma mark - Saving



- (BOOL) save {
	return [self saveWithErrorMessage:@"Could not save context"];
}

- (void) saveWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock {
    [self saveWithErrorMessage:@"Could not save context" completionBlock:completionBlock];
}

- (BOOL) saveWithErrorMessage:(NSString *)errorMessage {
	__block NSError *error = nil;
	__block BOOL success = NO;
    [self performBlockAndWait:^{
        success = [self save:&error];
    }];
	if (!success) {
		FLog(@"%@: %@ (%@)", errorMessage, [error localizedDescription], [error userInfo]);
	}	
	return success;
}

- (void) saveWithErrorMessage:(NSString *)errorMessage completionBlock:(void(^)(BOOL success, NSError *error))completionBlock {
	__block NSError *error = nil;
	__block BOOL success = NO;
    [self performBlockAndWait:^{
        success = [self save:&error];
    }];
	if (completionBlock) {
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(success, error);
		});
	}
}

- (BOOL) saveWithParent:(NSError **)error {
	__block NSError *saveError = nil;
	__block BOOL success = NO;
	
    [self performBlockAndWait:^{
        success = [self save:&saveError];
    }];
    if (success && self.parentContext) {
        [self.parentContext performBlockAndWait:^{ success = [self.parentContext save:&saveError]; }];
    }
	
	if (error) {
		*error = saveError;
	}
	return success;
}

- (void) saveWithParentWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock {
	__block NSError *saveError = nil;
	__block BOOL success = NO;
	
    [self performBlockAndWait:^{
        success = [self save:&saveError];
    }];
    if (success && self.parentContext) {
        [self.parentContext performBlockAndWait:^{ success = [self.parentContext save:&saveError]; }];
    }
	if (completionBlock) {
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(success, saveError);
		});
	}
}

- (void) performBlock:(void (^)())block savingWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock {
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self performBlockAndWait:block];
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self saveWithCompletionBlock:completionBlock];
//		});
//	});
}

- (void) performBlock:(void (^)())block savingWithParentWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock {
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self performBlockAndWait:block];
//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self saveWithParentWithCompletionBlock:completionBlock];
//		});
//	});
}

- (NSManagedObjectContext *) newChildContext {
    return [self newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext *) newChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    NSManagedObjectContext *child = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    child.parentContext = self;
    return child;
}



// ========================================================================== //

#pragma mark - Data Loading

- (BOOL) loadDefaultData:(NSURL *)plistURL error:(NSError **)error {
	
	NSDictionary *defaultData = [NSDictionary dictionaryWithContentsOfURL:plistURL];
	
	BOOL loaded = NO;
	NSError *localError = nil;
	
	@try {
		
		NSArray *sortedKeys = [defaultData keysSortedByValueWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSComparisonResult result = [[obj1 valueForKey:@"sequence"] compare:[obj2 valueForKey:@"sequence"]];
			return result;
		}];

		for (id key in sortedKeys) {
			NSDictionary *entityMapping = [defaultData objectForKey:key];
			
			NSString *entityClassName = [entityMapping objectForKey:@"entityClassName"];
			Class destinationClass = NSClassFromString(entityClassName);
			if (destinationClass == NULL) {
				NSDictionary *info = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not create a class named %@",entityClassName]};
				localError = [NSError errorWithDomain:kNSManagedObjectContext_FSQErrorDomain
												 code:kFSQCoreDataInvalidDefaultData 
											 userInfo:info];
				break;
			}
			
			NSArray *objects = [entityMapping objectForKey:@"objects"];
			if (NO == [objects isKindOfClass:[NSArray class]]) {
				NSDictionary *info = @{NSLocalizedDescriptionKey: @"Entity mapping must contain a list of objects to insert for each entity"};
				localError = [NSError errorWithDomain:kNSManagedObjectContext_FSQErrorDomain
												 code:kFSQCoreDataInvalidDefaultData 
											 userInfo:info];
				break;
			}
			NSUInteger mappedCount = 0;

			for (id data in objects) {
				NSManagedObject *object = nil;
				NSString *predicateFormat = [data objectForKey:@"<predicate>"];
				if (predicateFormat) {
					NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
					object = [destinationClass findOrCreateWithPredicate:predicate inContext:self];
					if ([object isInserted]) {
						[object updateWithObject:data merge:NO];
						loaded = YES;
						mappedCount++;
					}
				}
				else {
					object = [destinationClass createWithAttributes:data inContext:self];
					loaded = YES;
					mappedCount++;
				}
				//					FLog(@"data: %@",data);
				//					FLog(@"object: %@",object);				
			}
			FLog(@"Mapped %@ %@s",@(mappedCount), entityClassName);
			FLog(@"actual count: %@",@([destinationClass countInContext:self]));
		}

	}
	@catch (NSException *exception) {
		NSDictionary *info = @{NSLocalizedDescriptionKey: @"Default data plist must contain a valid entity mapping dictionary for each entity you wish to map"
							  , NSLocalizedFailureReasonErrorKey: [exception reason]};
		localError = [NSError errorWithDomain:kNSManagedObjectContext_FSQErrorDomain
										 code:kFSQCoreDataInvalidDefaultData 
									 userInfo:info];
	}
	
	if (error) {
		*error = localError;
	}


	return loaded;
}



@end
