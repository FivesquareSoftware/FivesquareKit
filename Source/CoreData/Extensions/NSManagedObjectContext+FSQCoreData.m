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

- (void) saveWithCompletionBlock:(void(^)(NSError *error))completionBlock {
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

- (void) saveWithErrorMessage:(NSString *)errorMessage completionBlock:(void(^)(NSError *error))completionBlock {
    
}

- (BOOL) saveWithParent:(NSError **)error {
	__block NSError *saveError = nil;
	__block BOOL success = NO;
	
    [self performBlockAndWait:^{
        success = [self save:&saveError];
    }];
    if (success && self.parentContext) {
        [self.parentContext performBlockAndWait:^{ success = [self.parentContext save:NULL]; }];
    }
	
	if (error) {
		*error = saveError;
	}
	return success;
}

- (void) saveWithParentWithCompletionBlock:(void(^)(NSError *error))completionBlock {
    
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

- (BOOL) loadDefaultDatafromPlistIfNeeded:(NSString *)plistName error:(NSError **)error {
	
	NSDictionary *defaultData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
	
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
			NSUInteger count = [destinationClass countInContext:self];
			NSUInteger mappedCount = 0;
			if (count < 1) {
				loaded = YES;
				for (id data in objects) {
					NSManagedObject *object = [destinationClass createInContext:self];
					[object updateWithObject:data merge:NO];
//					FLog(@"data: %@",data);
//					FLog(@"object: %@",object);
					mappedCount++;
				}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat"
				FLog(@"Mapped %u %@s",mappedCount, entityClassName);
				FLog(@"actual count: %u",[destinationClass countInContext:self]);
#pragma clang diagnostic pop
			}
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
