//
//  NSManagedObjectContext+FSQCoreData.h
//  FivesquareKit
//
//  Created by John Clayton on 4/18/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NSManagedObjectContext (FSQCoreData)

/** Saves the receiver synchronously using performBlockAndWait:, failing with a generic error message if the save fails. */
- (BOOL)save;
/** Saves the receiver asynchronously using performBlock: and dispatches the completionBlock on the main thread. */
- (void) saveWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock;

/** Saves the receiver synchronously using performBlockAndWait:, failing with the provided error message if the save fails. */
- (BOOL)saveWithErrorMessage:(NSString *)errorMessage;
/** Saves the receiver asynchronously using performBlock:,logs the provided error message if the save fails and dispatches the completionBlock on the main thread. */
- (void) saveWithErrorMessage:(NSString *)errorMessage completionBlock:(void(^)(BOOL success, NSError *error))completionBlock;

/** Saves the receiver synchronously and, if it has a parent, synchronously saves the parent using performBlockAndWait:.
 *  @returns YES if the receiver and its parent if any were saved successfully. 
 *  @param error contains any errors that occurred saving the receiver or its parent.
 */
- (BOOL) saveWithParent:(NSError **)error;

/** Saves the receiver asynchronously and, if it has a parent, asynchronously saves the parent using performBlock: dispatching the completionBlock on the main thread. */
- (void) saveWithParentWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock;

/** On the completion of some work saves the receiver and and dispatches the completionBlock on the main threa. */
- (void) performBlock:(void (^)())block savingWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock;
/** On the completion of some work saves the receiver and, if it has a parent, asynchronously saves the parent using performBlock:, then dispatches the completionBlock on the main threa. */
- (void) performBlock:(void (^)())block savingWithParentCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock;


/** @returns a child context of concurrency type NSPrivateQueueConcurrencyType. This context  must be messaged by calling performBlock: and may be used from any thread.  */
- (NSManagedObjectContext *) newChildContext;
- (NSManagedObjectContext *) newChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

/** Looks for a plist with the same value as #storeName and will attempt to load the objects it finds there into the database if the entities in the plist have a count of 0. The top-level elements of the plist should be dictionaries that include the following keys:
 *    - entityClassName - the class that corresponds to the entities to be inserted
 *    - sequence - the order in which the enity should be inserted, useful if relationships are going to be resolved at load time to create the destination objects first
 *    - objects - an array of the actual data to be mapped to each new entity
 *
 *  For example, the following xml would cause the Product entity to have one record created:
 * <key>Products</key>
 * <dict>
 *	<key>entityClassName</key>
 *	<string>MyProductClass</string>
 *	<key>sequence</key>
 *	<integer>1</integer>
 *	<key>objects</key>
 *	<array>
 *		<dict>
 *		<key>remote_ID</key>
 *		<integer>0</integer>
 *		</dict>
 *	</array>
 * </dict>
 *
 * Data is mapped onto newly created records using NSManagedObject#updateWithObject:merge:, and can handle mapping relationships as well as simple values. @see NSManagedObject+FSQCoreData for more information.
 *
 * @returns YES if any data was loaded.
 */
- (BOOL) loadDefaultData:(NSURL *)plistURL error:(NSError **)error;


@end
