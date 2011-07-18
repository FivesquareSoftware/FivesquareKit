//
//  FSQCoreDataManager.h
//  FivesquareKit
//
//  Created by John Clayton on 2/8/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface FSQCoreDataManager : NSObject {

}

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, copy) NSString *configurationName;
@property (nonatomic, copy) NSDictionary *storeOptions;
@property (nonatomic, strong) id mergePolicy;

/** If this is YES, and there is not yet a persistent store, and one exists in the 
 *  bundle with the same name, copies it into the database location first. The default
 *  is YES. */
@property (nonatomic, assign) BOOL copyDefaultDatabaseFromBundle;


/** Creates a persistent instance of a managed obect context intialized with NSMainQueueConcurrencyType concurrency type. This context can be messaged directly from the main thread or via performBlock: on backround threads. */
@property (readonly, strong) NSManagedObjectContext *mainContext;

/** A model located using the value of name or merged from all the models in the main bundle. */
@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
/** The common persistent store coordinator created with storeOptions. */
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


/** Initializes the manager with name. Name is used to locate a suitable model file and to create a persistent store on disk.  If a model with name does not exist, a merged model is created from the bundle. 
 *
 *  @param aName cannot be nil.
 */
- (id) initWithName:(NSString *)aName;

/** If a persitent store exists on disk and the current model version is not compatible with that store, will attempt to migrate the store either by running a mapping migration if one is found or attempting a lightweight migration. 
 * 
 *  @return YES if a migration was performed.
 */
- (BOOL) migrateIfNeeded:(NSError **)error;


/** Generates a new context connected to the common persistent store and via a child relationship to the #mainContext. This conext  must be messaged by calling performBlock: and may be used from any thread.
 *  @returns a child context of concurrency type NSPrivateQueueConcurrencyType
 */
- (NSManagedObjectContext *) newChildContext;

/** Generates a persistent coordinator store with the supplied options and using self.name. */
- (NSPersistentStoreCoordinator *) createPersistentStoreCoordinator:(NSDictionary *)someStoreOptions error:(NSError **)error;


- (NSDictionary *) storeMetadata;
+ (NSString *) databaseDirectory;



@end
