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
	NSError *error = nil;
	BOOL success = [self save:&error];
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


@end
