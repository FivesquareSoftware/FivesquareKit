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

- (BOOL) saveWithErrorMessage:(NSString *)errorMessage {
	__block NSError *error = nil;
	__block BOOL success = NO;
	success = [self save:&error];
	if (!success) {
		FLog(@"%@: %@ (%@)", errorMessage, [error localizedDescription], [error userInfo]);
	}	
	return success;
}

- (NSManagedObjectContext *) newChildContext {
    NSManagedObjectContext *child = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    child.parentContext = self;
    return child;
}

- (BOOL) saveWithParent:(NSError **)error {
	__block NSError *saveError = nil;
	__block BOOL success = NO;
	
	if ( (success = [self save:&saveError]) ) {
		if (self.parentContext) {
			[self.parentContext performBlock:^{ success = [self.parentContext save:NULL]; }];
		}
	}
	
	if (error) {
		*error = saveError;
	}
	return success;
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
				NSDictionary *info = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Could not create a class named %@",entityClassName] forKey:NSLocalizedDescriptionKey];
				localError = [NSError errorWithDomain:kNSManagedObjectContext_FSQErrorDomain
												 code:kFSQCoreDataInvalidDefaultData 
											 userInfo:info];
				break;
			}
			
			NSArray *objects = [entityMapping objectForKey:@"objects"];
			if (NO == [objects isKindOfClass:[NSArray class]]) {
				NSDictionary *info = [NSDictionary dictionaryWithObject:@"Entity mapping must contain a list of objects to insert for each entity"
																 forKey:NSLocalizedDescriptionKey];
				localError = [NSError errorWithDomain:kNSManagedObjectContext_FSQErrorDomain
												 code:kFSQCoreDataInvalidDefaultData 
											 userInfo:info];
				break;
			}
			NSUInteger count = [destinationClass countInContext:self];
			NSUInteger mappedCount = 0;
			if (count < 1) {
				for (id data in objects) {
					loaded = YES;
					NSManagedObject *object = [destinationClass createInContext:self];
					[object updateWithObject:data merge:NO];
//					FLog(@"data: %@",data);
//					FLog(@"object: %@",object);
					mappedCount++;
				}
				FLog(@"Mapped %u %@s",mappedCount, entityClassName);
				FLog(@"actual count: %u",[destinationClass countInContext:self]);
			}
		}

	}
	@catch (NSException *exception) {
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"Default data plist must contain a valid entity mapping dictionary for each entity you wish to map", NSLocalizedDescriptionKey
							  , [exception reason], NSLocalizedFailureReasonErrorKey 
							  , nil];
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
