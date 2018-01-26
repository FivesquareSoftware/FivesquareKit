//
//  FSQCoreDataStack.h
//  FivesquareKit
//
//  Created by John Clayton on 2/8/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>


extern NSString *kFSQCoreDataStackErrorDomain;
enum  {
	kFSQCoreDataStackErrorCodeUbiquityNotAvailable			= 9000,
	kFSQCoreDataStackErrorCodeFailedToLoadUbiquitousStore	= 9001,
	kFSQCoreDataStackErrorCodeFailedToLoadAnyStore			= 9002
};

typedef void(^FSQCoreDataStackReadyBlock)(NSManagedObjectContext *mainContext);


@interface FSQCoreDataStack : NSObject

// Delegation

@property (nonatomic, copy) void(^migrationHandler)(FSQCoreDataStack *stack, NSURL *sourceStore);


// Base attributes

@property (nonatomic, copy, readonly) NSString *modelName;
@property (nonatomic, copy, readonly) NSString *storeName;

/** Used to locate an initial data set in the main bundle. The data may be in either a sqlite store or a plist, with a store taking precedence. Defaults to #storeName. 
 *  @see NSManagedObjectContext+
 *
 */
@property (nonatomic, strong) NSString *seedStore;

// Core Data options

/** Takes effect the next time the receiver is reloaded. */
@property (nonatomic, copy) NSString *configurationName;

/** Takes effect the next time the receiver is reloaded. */
@property (nonatomic, copy) NSDictionary *storeOptions;

/** Effective for new managed object contexts. */
@property (nonatomic, strong) id mergePolicy;


// Locations

/** By default, persistent stores are placed in ~/Application Support/CoreData. You can change this location by passing your own location to #initWithModelName:persistentStore:persistentStoresDirectory:. */
@property (nonatomic, strong, readonly) NSURL *persistentStoresDirectoryURL;


// Core Data stack objects


/** A model located using the value of #modelName or merged from all the models in the main bundle when #modelName is nil. */
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/** The common persistent store coordinator created with storeOptions. */
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/** @returns the currently in use store, which may be either ubiquitous or local-only, or nil if it has yet to be initialized. */
@property (nonatomic, readonly) NSPersistentStore *persistentStore;

/** @returns the URL that the persistent store is or will be located at. This may be called before the stack has been initialized to allow you to perform file system operations as needed. */
@property (nonatomic, readonly) NSURL *persistentStoreURL;

/** @returns the metadata for the currently loaded persistent store or nil if it has yet to be initialized. */
@property (nonatomic, readonly) NSDictionary *storeMetadata;

/** Creates a persistent instance of a managed obect context intialized with NSMainQueueConcurrencyType concurrency type. This context can be messaged directly from the main thread or via performBlock: on backround threads. May return nil if the core stack has not been initialized, @see #initializeWithCompletionBlock:. */
@property (strong, readonly) NSManagedObjectContext *mainContext;


// State information

@property (nonatomic, strong) NSError *lastError;


// Creating Instances

/** @see initWithModelName:persistentStore:persistentStoresDirectory:. */
- (id) initWithModelName:(NSString *)modelName persistentStore:(NSString *)storeName;

/** Initializes the manager with a model and sets up a persisent store coordinator.
 *  @param modelName is used to locate a suitable model file and to create a persistent store on disk.  If a model with modelName does not exist, a merged model is created from the bundle.
 *  @param storeName will be used to create the database file on disk. storeName cannot be nil.
 *  @param persistentStoresDirectoryURL will override the default location used to keep persistent stores.
 */
- (id) initWithModelName:(NSString *)modelName persistentStore:(NSString *)storeName persistentStoresDirectory:(NSURL *)persistentStoresDirectoryURL;

/** This must be called once before the stack or any context created from it are used to do any work. Handles model migration and setting up the persistent store as either local or ubiquitous depending on the value of #isUbiquitous and the availability of an iCloud account. Calling this method more than once has no effect. Call #reloadWithCompletionBlock: if you want to re-initialize the receiver. */
- (void) initializeWithCompletionBlock:(void(^)(FSQCoreDataStack *stack,NSError *error))completionBlock;

/** Drops the persistent store and reinitializes the receiver, handling ubiquity (re)configuration and migration as needed. */
- (void) reloadWithCompletionBlock:(void(^)(NSError *error))completionBlock;


- (void) performOnMainContextWhenReady:(FSQCoreDataStackReadyBlock)block;



/** Generates a new context connected to the common persistent store and, via a parent-child relationship, to the #mainContext. This context uses NSPrivateQueueConcurrencyType and must be messaged by calling performBlock:. It may be used from any thread. May return nil if the stack has not completed initialization yet or is in the process of reloading, @see #initializeWithCompletionBlock:.
 *  @returns a child context of concurrency type NSPrivateQueueConcurrencyType
 */
- (NSManagedObjectContext *) newChildContext;
- (NSManagedObjectContext *) newChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;
- (NSManagedObjectContext *) newConcurrentContext;


@end
