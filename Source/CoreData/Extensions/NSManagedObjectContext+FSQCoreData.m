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

@implementation NSManagedObjectContext (FSQCoreData)


- (BOOL) save {
	return [self saveWithErrorMessage:@"Could not save context"];
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

- (NSManagedObjectContext *) newChildContext {
    NSManagedObjectContext *child = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    child.parentContext = self;
    return child;
}

- (BOOL) saveWithParent:(NSError **)error {
	__block NSError *saveError = nil;
	__block BOOL success = NO;
	
	[self performBlockAndWait:^{
		__autoreleasing NSError *localError = nil;
		if ( (success = [self save:&localError]) ) {
			if (self.parentContext) {
				[self.parentContext performBlock:^{[self.parentContext save:NULL];}];
			}
		}
		if (localError) {
			saveError = localError;
		}
	}];
	if (error) {
		*error = saveError;
	}
	return success;
}


@end
