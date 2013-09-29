//
//  FSQManagedObject.h
//  FivesquareKit
//
//  Created by John Clayton on 1/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString *kFSQManagedObjectCreatedAtKey;
extern NSString *kFSQManagedObjectUpdatedAtKey;
extern NSString *kFSQManagedObjectDeletedAtKey;
extern NSString *kFSQManagedObjectUniqueIdentifierKey;


@interface FSQManagedObject : NSManagedObject

- (void) markForDeletion;

@end
