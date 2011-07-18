//
//  NSManagedObjectContext+FSQCoreData.h
//  FivesquareKit
//
//  Created by John Clayton on 4/18/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NSManagedObjectContext (FSQCoreData)

/** Saves the context, failing with a generic error message if the save fails. */
- (BOOL)save;

/** Saves the context, failing with the provided error message if the save fails. */
- (BOOL)saveWithErrorMessage:(NSString *)errorMessage;

/** @returns a child context of concurrency type NSPrivateQueueConcurrencyType. This conext  must be messaged by calling performBlock: and may be used from any thread.  */
- (NSManagedObjectContext *) newChildContext;

@end
