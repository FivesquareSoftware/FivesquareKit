//
//  FSQCoreDataStack.h
//  FivesquareKit
//
//  Created by John Clayton on 2/8/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface FSQCoreDataStack : NSObject {

}

@property (nonatomic, copy, readonly) NSString *modelName;
@property (nonatomic, copy, readonly) NSString *storeName;

@property (nonatomic, copy) NSString *configurationName;
@property (nonatomic, copy) NSDictionary *storeOptions;
@property (nonatomic, strong) id mergePolicy;

/** If this is YES, and there is not yet a persistent store, and one exists in the 
 *  bundle with the same name, copies it into the database location first. The default
 *  is NO (because this will break with iCloud support). */
@property (nonatomic, assign) BOOL copyDefaultDatabaseFromBundle;
 

/** Creates a persistent instance of a managed obect context intialized with NSMainQueueConcurrencyType concurrency type. This context can be messaged directly from the main thread or via performBlock: on backround threads. */
@property (readonly, strong) NSManagedObjectContext *mainContext;

/** A model located using the value of #modelName or merged from all the models in the main bundle. */
@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
/** The common persistent store coordinator created with storeOptions. */
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


/** Initializes the manager with a model and sets up a persisent store coordinator. 
 *  @param modelName is used to locate a suitable model file and to create a persistent store on disk.  If a model with modelName does not exist, a merged model is created from the bundle. 
 *  @param storeName will be used to create the database file on disk. storeName cannot be nil.
 */
- (id) initWithModelName:(NSString *)modelName persistentStore:(NSString *)storeName;

/** If a persitent store exists on disk and the current model version is not compatible with that store, will attempt to migrate the store either by running a mapping migration if one is found or attempting a lightweight migration. 
 * 
 *  @return YES if a migration was performed.
 */
- (BOOL) migrateIfNeeded:(NSError **)error;


/** Generates a new context connected to the common persistent store and via a child relationship to the #mainContext. This conext  must be messaged by calling performBlock: and may be used from any thread.
 *  @returns a child context of concurrency type NSPrivateQueueConcurrencyType
 */
- (NSManagedObjectContext *) newChildContext;

/** Generates a persistent coordinator store with the supplied options and using #storeName. */
- (NSPersistentStoreCoordinator *) createPersistentStoreCoordinator:(NSDictionary *)someStoreOptions error:(NSError **)error;


- (NSDictionary *) storeMetadata;
+ (NSString *) databaseDirectory;



@end
