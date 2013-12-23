//
//  FSQCoreDataStack.m
//  FivesquareKit
//
//  Created by John Clayton on 2/8/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQCoreDataStack.h"

#import <objc/runtime.h>

#import "FSQSandbox.h"
#import "FSQLogging.h"
#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"
#import "NSString+FSQFoundation.h"
#import "NSManagedObjectContext+FSQCoreData.h"
#import "NSError+FSQFoundation.h"
#import "NSDictionary+FSQFoundation.h"


#ifndef FSQCoreDataLogging
#define FSQCoreDataLogging  DEBUG && 1
#endif

#if FSQCoreDataLogging
#define CoreDataLog(stack, frmt, ...) FLogMark( ([NSString stringWithFormat:@"CORE DATA: %@",stack.storeName]) ,frmt, ##__VA_ARGS__)
#else
#define CoreDataLog(stack,frmt, ...)
#endif

NSString *kFSQCoreDataStackErrorDomain = @"FSQCoreDataStack Error Domain";
static NSString *kFSQCoreDataStackSqliteExtension = @"sqlite";


@interface FSQCoreDataStack()

@property (nonatomic, copy, readwrite) NSString *modelName;
@property (nonatomic, copy, readwrite) NSString *storeName;
@property (nonatomic, strong, readwrite) NSURL *persistentStoresDirectoryURL;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;


// Private

@property BOOL isInitializing;
@property (getter = wasInitialized) BOOL initialized;

@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSURL *localStoreURL;
@property (nonatomic, strong) NSPersistentStore *localStore;

@property (nonatomic, strong) NSMutableSet *readyBlocks;

@end



@implementation FSQCoreDataStack {
    dispatch_queue_t _setupQueue;
}


// ========================================================================== //

#pragma mark - Properties




// Locations

@synthesize persistentStoresDirectoryURL = _persistentStoresDirectoryURL;
- (NSURL *) persistentStoresDirectoryURL {
    if (nil == _persistentStoresDirectoryURL) {
        NSString *supportDir = [FSQSandbox applicationSupportDirectory];
        NSString *persistentStoresDir = [supportDir stringByAppendingPathComponent:@"CoreData"];
        
		NSError *error = nil;
		BOOL success = [self _createPersistentStoresDirectory:persistentStoresDir error:&error];
        if (success) {
            _persistentStoresDirectoryURL = [NSURL fileURLWithPath:persistentStoresDir];
            CoreDataLog(self,@"Using directory %@ for persistent stores",[_persistentStoresDirectoryURL path]);
        }
    }
    return _persistentStoresDirectoryURL;
}

- (void) setPersistentStoresDirectoryURL:(NSURL *)persistentStoresDirectoryURL {
	if (_persistentStoresDirectoryURL != persistentStoresDirectoryURL) {
		if (persistentStoresDirectoryURL) {
			NSError *error = nil;
			BOOL success = [self _createPersistentStoresDirectory:[persistentStoresDirectoryURL path] error:&error];
			if (success) {
				_persistentStoresDirectoryURL = persistentStoresDirectoryURL;
			}
		}
	}
}

// Stack Objects

- (NSManagedObjectModel *)managedObjectModel {
	@synchronized(self) {
		if(_managedObjectModel == nil) {
			if(self.modelURL) { // will be nil if the file does not exist
				_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
			}
            else {
				_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
			}
		}
	}
	return _managedObjectModel;
}


@dynamic persistentStore;
- (NSPersistentStore *) persistentStore {
    if (nil == _persistentStoreCoordinator) {
        return nil;
    }
    return [_persistentStoreCoordinator persistentStoreForURL:self.persistentStoreURL];
}

@dynamic persistentStoreURL;
- (NSURL *) persistentStoreURL {
    return self.localStoreURL;
}

- (NSDictionary *) storeMetadata {
	NSError *error = nil;
	NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.persistentStoreURL error:&error];
	if(storeMetadata == nil) {
		FLogError(error,@"Couldn't get store metadata!");
	}
	
	return storeMetadata;
}

@synthesize mainContext = _mainContext;
- (NSManagedObjectContext *) mainContext {
	if (nil == _mainContext && self.wasInitialized) {
		_mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		_mainContext.persistentStoreCoordinator = _persistentStoreCoordinator;
	}
	return _mainContext;
}


#pragma mark - -- Private



// Locations


- (NSURL *) modelURL {
	if(_modelURL == nil && [NSString isNotEmpty:_modelName]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:_modelName ofType:@"mom"];
        if (path == nil) {
            path = [[NSBundle mainBundle] pathForResource:_modelName ofType:@"momd"];
        }
        _modelURL = [NSURL fileURLWithPath:path];
	}
	return _modelURL;
}

- (NSURL *) localStoreURL {
    if (nil == _localStoreURL) {
        _localStoreURL = [[self.persistentStoresDirectoryURL URLByAppendingPathComponent:self.storeName] URLByAppendingPathExtension:kFSQCoreDataStackSqliteExtension];
        CoreDataLog(self,@"Local store URL: %@",_localStoreURL);
    }
    return _localStoreURL;
}





// ========================================================================== //

#pragma mark - Object

- (void)dealloc {

}

- (id) initWithModelName:(NSString *)modelName persistentStore:(NSString *)storeName {
	return [self initWithModelName:modelName persistentStore:storeName persistentStoresDirectory:nil];
}

- (id) initWithModelName:(NSString *)modelName persistentStore:(NSString *)storeName persistentStoresDirectory:(NSURL *)persistentStoresDirectoryURL {
	
	if (storeName == nil) {
		self = nil;
		FSQAssert(storeName != nil,@"storeName cannot be nil");
		return self;
	}
	self = [super init];
	if (self != nil) {
		_modelName = [modelName copy];
		_storeName = storeName;
		_seedStore = _storeName;
		self.persistentStoresDirectoryURL = persistentStoresDirectoryURL;
		
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
//        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//        _mainContext.persistentStoreCoordinator = _persistentStoreCoordinator;		
        _storeOptions = @{};
        _setupQueue = dispatch_queue_create("com.fivesquaresoftware.FSQCoreDataManager.steupQueue", NULL);
		_readyBlocks = [NSMutableSet new];
	}
	return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ model: %@ storeName: %@",[super description],self.modelName,self.storeName];
}



// ========================================================================== //

#pragma mark - Stack Setup


- (void) initializeWithCompletionBlock:(void(^)(FSQCoreDataStack *stack,NSError *error))completionBlock {
    if (NO == self.wasInitialized && NO == self.isInitializing) {
		self.isInitializing = YES;
		[self _initializeWithCompletionBlock:^(NSError *error) {
			if (nil == error) {
				self.initialized = YES;
			}
			self.isInitializing = NO;
			if (completionBlock) {
				completionBlock(self,error);
			}
			for (FSQCoreDataStackReadyBlock readyBlock in _readyBlocks) {
				dispatch_async(dispatch_get_main_queue(), ^{
					readyBlock(self.mainContext);
				});
			}
			[_readyBlocks removeAllObjects];
		}];
    }
}

- (void) reloadWithCompletionBlock:(void(^)(NSError *error))completionBlock {
    [self _initializeWithCompletionBlock:completionBlock];
}

- (void) _initializeWithCompletionBlock:(void(^)(NSError *error))completionBlock {
    dispatch_async(_setupQueue, ^{
        [self _dropPersistentStore];
		__strong NSError *loadError;
        NSError *error = nil;
        [self _initializeStoresError:&error];
		loadError = error;
        CoreDataLog(self,@"Initialization complete");
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(loadError);
            });
        }
    });
}

- (void) performOnMainContextWhenReady:(FSQCoreDataStackReadyBlock)block {
	[_readyBlocks addObject:block];
}


// ========================================================================== //

#pragma mark - Setup (Internal)

/** These must all be run on the internal queue, do not call these from the main thread. */

- (BOOL) _initializeStoresError:(NSError **)errorPtr {
    CoreDataLog(self,@"Initializing persistent store");
    FSQAssert([_persistentStoreCoordinator persistentStores].count < 1, @"Tried to load persistent stores when they are already open! %@",[_persistentStoreCoordinator persistentStores]);	

	BOOL loadedStore = NO;
    __block NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];


//	NSURL *persistentStoresDirectoryURL = self.persistentStoresDirectoryURL;
	NSURL *localStoreURL = self.localStoreURL;
	NSString *localStorePath = [localStoreURL path];
	
	BOOL localStoreFileExists = [fm fileExistsAtPath:localStorePath];

	if (NO == localStoreFileExists) {
		[self _seedStoreAtURL:localStoreURL withStoreOptions:_storeOptions error:&error];
	}
	
	loadedStore = [self _loadLocalStore:&error];
	if (NO == loadedStore) {
		// MAN, ARE WE IN TROUBLE ... this is a crash if it's not handled
		NSString *msg = [NSString stringWithFormat:@"Unable to load any peristent store for %@",self];
		NSError *seriousError = [NSError errorWithError:error domain:kFSQCoreDataStackErrorDomain code:kFSQCoreDataStackErrorCodeFailedToLoadAnyStore localizedDescription:msg];
		error = seriousError;
	}
			
    if (errorPtr) {
        *errorPtr = error;
    }
	if (error) {
		_lastError = error;
	}
    
    return loadedStore;
}

- (BOOL) _loadLocalStore:(NSError **)errorPtr {
    CoreDataLog(self,@"Loading local store");
    NSError *error = nil;
    _localStore = [self _openStoreAtURL:self.localStoreURL options:_storeOptions error:&error];
    BOOL success = (_localStore != nil);
    if (success) {
        CoreDataLog(self,@"..loaded local store");
    }
    else {
        FLogError(error, @"Could not load local store!");
        if (errorPtr) {
            *errorPtr = error;
        }
    }
    return success;
}

- (NSPersistentStore *) _openStoreAtURL:(NSURL *)storeURL options:(NSDictionary *)storeOptions error:(NSError **)errorPtr {
    CoreDataLog(self,@"Opening store: %@",[storeURL lastPathComponent]);
	
    NSDate *start FSQ_MAYBE_UNUSED = [NSDate date];
    
    NSMutableDictionary *options = [NSMutableDictionary new];
    [options addEntriesFromDictionary:storeOptions];
    [options addEntriesFromDictionary:[self _migrationOptionsForStoreAtURL:storeURL]];
    
    NSError *storeError = nil;
    CoreDataLog(self,@"Adding store with options: %@",options);
    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:_configurationName URL:storeURL options:options error:&storeError];
	if (nil == persistentStore) {
		if(storeError) {
			FLogError(storeError, @"Unable to add store for URL %@ with options %@",storeURL, options);
		}
	}
    if (errorPtr) {
        *errorPtr = storeError;
    }
    
    FLogTime(start, @"_openStoreAtURL:%@",[storeURL lastPathComponent]);
    
    return persistentStore;
}

- (NSDictionary *) _migrationOptionsForStoreAtURL:(NSURL *)storeURL {
    CoreDataLog(self,@"Getting migration options for %@",[storeURL lastPathComponent]);
	
	NSMutableDictionary *migrationOptions = [NSMutableDictionary new];
    [migrationOptions addEntriesFromDictionary:@{NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES)}];
	
    NSError *error = nil;
    
    CoreDataLog(self,@"Getting metadata for store on disk");
	NSDictionary *currentStoreMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
    if(currentStoreMetadata == nil) {
        if (error) {
            FLogError(error, @"Unable to get metadata for current store");
        }
        return migrationOptions;
    }
    
    CoreDataLog(self,@"Getting source and destination model");
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:currentStoreMetadata];
	NSManagedObjectModel *destinationModel = self.managedObjectModel;

//    CoreDataLog(self,@"Checking compatibility");
//    BOOL modelCompatibleWithExistingStore = [destinationModel isConfiguration:_configurationName compatibleWithStoreMetadata:currentStoreMetadata];
//
//    if (modelCompatibleWithExistingStore) {
//        CoreDataLog(self,@"Compatible stores, no migration options");
//        return migrationOptions;
//    }

//    [migrationOptions addEntriesFromDictionary:@{NSMigratePersistentStoresAutomaticallyOption: @(YES)}];
    
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinationModel];
    if (mappingModel) {
        [migrationOptions removeObjectForKey:NSInferMappingModelAutomaticallyOption];
        CoreDataLog(self,@"Using mapping model migration");
    }
    else {
        CoreDataLog(self,@"Using lightweight migration");
    }
    
    return migrationOptions;
}

- (BOOL) _seedStoreAtURL:(NSURL *)targetStoreURL withStoreOptions:(NSDictionary *)targetStoreOptions error:(NSError **)errorPtr {
	CoreDataLog(self, @"Checking if default data exists for store at %@",[targetStoreURL lastPathComponent]);
    __block BOOL success = YES;
	BOOL loaded = NO;
	BOOL found = NO;
    __block NSError *error = nil;
	NSFileManager *fm = [NSFileManager new];
	
	NSURL *sqliteURL = [[NSBundle mainBundle] URLForResource:_seedStore withExtension:@"sqlite"];
	if ([fm fileExistsAtPath:[sqliteURL path]]) {
		CoreDataLog(self,@"Copying in default store");
		found = YES;
		if (NO == [targetStoreOptions hasKey:NSPersistentStoreUbiquitousContentURLKey]) {
			success = [fm copyItemAtURL:sqliteURL toURL:targetStoreURL error:&error];
			loaded = success;
			if (NO == success) {
				FLogError(error, @"Failed to copy default data from store at %@",sqliteURL);
			}
		}
		else {
			CoreDataLog(self,@"Migrating in default store");
			//TODO: PSC store migration to make sure ubiquity sees the changes
//			NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
//			[coordinator migratePersistentStore:￼ toURL:￼ options:￼ withType:￼ error:￼]
		}
	}
	if (NO == loaded) {
		NSURL *plistURL = [[NSBundle mainBundle] URLForResource:_seedStore withExtension:@"plist"];
		if ([fm fileExistsAtPath:[plistURL path]]) {
			CoreDataLog(self,@"Loading default plist");
			found = YES;
			NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
			NSPersistentStore *persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:_configurationName URL:targetStoreURL options:targetStoreOptions error:&error];
			if (persistentStore) {				
				NSManagedObjectContext *migrationContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
				migrationContext.persistentStoreCoordinator = coordinator;
				[migrationContext performBlockAndWait:^{
					__autoreleasing NSError *loadError = nil;
					[migrationContext loadDefaultData:plistURL error:&loadError];
					success = (nil == loadError);
					if (success) {
						success = [migrationContext save:&loadError];
					}
					if (NO == success) {
						FLogError(loadError, @"Failed to load default data from plist at %@, removing store",plistURL);
						if (NO == [fm removeItemAtURL:targetStoreURL error:&loadError]) {
							// HELP!?
						}
					}
					if (loadError) {
						error = loadError;
					}
					
				}];
				migrationContext = nil;
				coordinator = nil;
			}
			else {
				FLogError(error, @"Failed to add persistent store to load default data");
				success = NO;
			}
		}
	}
	
    if (errorPtr) {
		*errorPtr = error;
	}
	if (NO == found) {
		CoreDataLog(self, @".. didn't find any");
	}
	
    return success;
}

- (BOOL) _migrateDataFromStore:(NSURL *)sourceStoreURL toURL:(NSURL *)destinationStoreURL storeOptions:(NSDictionary *)destinationStoreOptions unique:(BOOL)shouldUnique error:(NSError **)errorPtr {
    BOOL success = YES;
	
    FLogDebug(@"Wants to overwrite data at %@ with data at %@",destinationStoreURL,sourceStoreURL);

	//TODO: remove any store we find at destinationStoreURL
		
    return success;
}

- (void) _dropPersistentStore {
    NSError *error = nil;
    if (_localStore) {
        if (NO == [self _dropStore:_localStore error:&error]) {
            FLogError(error, @"Couldn't drop local store!");
        }
        else {
            _localStore = nil;
        }
    }
}

- (BOOL) _dropStore:(NSPersistentStore *)store error:(NSError **)errorPtr {
    if (nil == store.persistentStoreCoordinator) {
        return YES;
    }
	
    NSError *error = nil;
    BOOL success = [_persistentStoreCoordinator removePersistentStore:store error:&error];
    if (NO == success) {
        FLogError(error, @"Failed to drop store %@!",[store.URL lastPathComponent]);
    }
    
    if (errorPtr) {
        *errorPtr = error;
    }
    return success;
}

- (BOOL) _destroyStore:(NSPersistentStore *)store error:(NSError **)errorPtr {
    NSParameterAssert(store != nil);
    NSURL *storeURL = store.URL;
    NSError *error = nil;
    BOOL success = NO;
    success = [self _dropStore:store error:&error];
    if (success) {
        NSFileManager *fm = [NSFileManager new];
        if (NO == [fm removeItemAtURL:storeURL error:&error]) {
            FLogError(error, @"Unable to delete store!");
            success = NO;
        }
    }
	
    if (errorPtr) {
        *errorPtr = error;
    }
    return success;
}



// ========================================================================== //

#pragma mark - Public


- (NSManagedObjectContext *) newChildContext {
    return [_mainContext newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
}

- (NSManagedObjectContext *) newChildContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    return [_mainContext newChildContextWithConcurrencyType:concurrencyType];
}

- (NSManagedObjectContext *) newConcurrentContext {
	if (NO ==self.wasInitialized) {
		return nil;
	}
	NSManagedObjectContext *concurrentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	concurrentContext.persistentStoreCoordinator = _persistentStoreCoordinator;
	return concurrentContext;
}


// ========================================================================== //

#pragma mark - Helpers



- (BOOL) _createPersistentStoresDirectory:(NSString *)persistentStoresDir error:(NSError **)errorPtr {
	NSFileManager *fm = [NSFileManager new];
	BOOL exists = [fm fileExistsAtPath:persistentStoresDir isDirectory:NULL];
	BOOL success = exists;
	NSError *error = nil;
	if(NO == exists) {
		[fm createDirectoryAtPath:persistentStoresDir withIntermediateDirectories:YES attributes:NULL error:&error];
		exists = [fm fileExistsAtPath:persistentStoresDir isDirectory:NULL]; // this is the only way to know if fm did what we needed, cause NO could just mean it didn't have to, or failure
		success = exists;
		FSQAssert(success, @"Could not create persistent stores directory! %@ (%@)",[error localizedDescription],[error userInfo]);
		if (NO == success) {
			FLogError(error, @"Could not create persistent stores directory!");
		}
	}
	
	if (errorPtr) {
		*errorPtr = error;
	}
	return success;
}

- (BOOL) _removeFile:(NSURL *)fileURL error:(NSError **)errorPtr {
    NSParameterAssert(fileURL != nil);
    NSError *error = nil;
    BOOL success = NO;
	NSFileManager *fm = [NSFileManager new];
	success = [fm removeItemAtURL:fileURL error:&error];
	if (NO == success) {
		FLogError(error, @"Unable to delete file!");
	}
	
    if (errorPtr) {
        *errorPtr = error;
    }
    return success;
}


@end


