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

#ifndef FSQCoreDataSupportUbiquity
#define FSQCoreDataSupportUbiquity 0
#endif


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

typedef NS_OPTIONS(NSUInteger, FSQCoreDataStackUbiquityTransition) {
    FSQCoreDataStackUbiquityTransitionNone					= 0,
    FSQCoreDataStackUbiquityTransitionIdentityChanged		= 1 << 0,
    FSQCoreDataStackUbiquityTransitionIdentityRemoved		= 1 << 1,
    FSQCoreDataStackUbiquityTransitionDataReset				= 1 << 2,
    FSQCoreDataStackUbiquityTransitionUbiquityEnabled		= 1 << 3,
    FSQCoreDataStackUbiquityTransitionUbiquityDisabled		= 1 << 4,
};

@interface FSQCoreDataStackUbiquityState : NSObject
@property (nonatomic) BOOL ubiquitous;
@property (nonatomic, strong) id ubiquityToken;
@property (nonatomic) BOOL ubiquitousContentWasDeleted;

+ (id) withState:(FSQCoreDataStackUbiquityState*)state;
- (FSQCoreDataStackUbiquityTransition) transitionMaskForTargetState:(FSQCoreDataStackUbiquityState*)targetState;

@end

@implementation FSQCoreDataStackUbiquityState

+ (id) withState:(FSQCoreDataStackUbiquityState*)state {
	FSQCoreDataStackUbiquityState *newState = [FSQCoreDataStackUbiquityState new];
	newState.ubiquitous = state.ubiquitous;
	newState.ubiquityToken = state.ubiquityToken;
	newState.ubiquitousContentWasDeleted = state.ubiquitousContentWasDeleted;
	return newState;
}
- (FSQCoreDataStackUbiquityTransition) transitionMaskForTargetState:(FSQCoreDataStackUbiquityState*)targetState {
	FSQCoreDataStackUbiquityTransition transitionMask = FSQCoreDataStackUbiquityTransitionNone;
	
	BOOL targetIsUbiquitous = targetState.ubiquitous;
	id targetUbiquityToken = targetState.ubiquityToken;
	BOOL targetUbiquitousContentWasDeleted = targetState.ubiquitousContentWasDeleted;
	
	
	if(targetIsUbiquitous != _ubiquitous) {
		transitionMask |= (targetIsUbiquitous ? FSQCoreDataStackUbiquityTransitionUbiquityEnabled : FSQCoreDataStackUbiquityTransitionUbiquityDisabled);
	}
	
	if (targetUbiquityToken != _ubiquityToken) {
		if (targetUbiquityToken) {
			transitionMask |= FSQCoreDataStackUbiquityTransitionIdentityChanged;
		}
		else {
			transitionMask |= FSQCoreDataStackUbiquityTransitionIdentityRemoved;
		}
	}
	
	if (targetUbiquitousContentWasDeleted) {
		transitionMask |= FSQCoreDataStackUbiquityTransitionDataReset;
	}
	
	return transitionMask;
}

- (BOOL) isEqual:(id)object {
	if (NO == [object isKindOfClass:[FSQCoreDataStackUbiquityState class]]) {
		return NO;
	}
	FSQCoreDataStackUbiquityState *otherState = (FSQCoreDataStackUbiquityState *)object;
	if (self.ubiquitous != otherState.ubiquitous || self.ubiquityToken != otherState.ubiquityToken || self.ubiquitousContentWasDeleted != otherState.ubiquitousContentWasDeleted) {
		return NO;
	}
	return YES;
}

- (NSUInteger) hash {
	return [[NSString stringWithFormat:@"%@%@%@",@(self.ubiquitous),self.ubiquityToken,@(self.ubiquitousContentWasDeleted)] hash];
}

@end


@interface FSQCoreDataStack()

@property (nonatomic, copy, readwrite) NSString *modelName;
@property (nonatomic, copy, readwrite) NSString *storeName;
@property (nonatomic, strong, readwrite) NSURL *persistentStoresDirectoryURL;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;



// Private

@property (getter = wasInitialized) BOOL initialized;
@property (nonatomic, getter = isSuspended) BOOL suspended;


@property (nonatomic, strong) FSQCoreDataStackUbiquityState *ubiquityState;
@property (nonatomic, strong) FSQCoreDataStackUbiquityState *suspendedUbiquityState;
@property (nonatomic, strong) id ubiquityToken;
@property (nonatomic, readonly) NSString *ubiquityIdentifier;
@property (nonatomic) BOOL ubiquitousContentWasDeleted;
@property (nonatomic, readonly) BOOL iCloudAvailable;

@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, readonly) NSURL *ubiquitousStoreURL;
@property (nonatomic, strong) NSURL *ubiquityContainerURL;
@property (nonatomic, readonly) NSURL *ubiquitousTransactionsDataURL;
@property (nonatomic, readonly) NSDictionary *ubiquitousStoreOptions;
@property (nonatomic, strong) NSURL *localStoreURL;
@property (nonatomic, strong) NSPersistentStore *ubiquitousStore;
@property (nonatomic, strong) NSPersistentStore *localStore;


@property (nonatomic, strong) id ubiquityIdentityObserver;
@property (nonatomic, strong) id applicationPausedObserver;
@property (nonatomic, strong) id applicationResumedObserver;

@end



@implementation FSQCoreDataStack {
    dispatch_queue_t _setupQueue;
}


// ========================================================================== //

#pragma mark - Properties




#pragma mark - -- Public



// Ubiquity

@dynamic ubiquitous;
- (void) setUbiquitous:(BOOL)ubiquitous {
#if FSQCoreDataSupportUbiquity
    if (_ubiquityState.ubiquitous != ubiquitous) {
		if (self.suspended) {
			_suspendedUbiquityState.ubiquitous = ubiquitous;
		}
		else {
			BOOL previousUbiquity = _ubiquityState.ubiquitous;
			_ubiquityState.ubiquitous = ubiquitous;
			FSQCoreDataStackUbiquityTransition transition = ubiquitous ? FSQCoreDataStackUbiquityTransitionUbiquityEnabled : FSQCoreDataStackUbiquityTransitionUbiquityDisabled;
			[self initializeWithUbiquityTransition:transition completionBlock:^(NSError *error) {
				CoreDataLog(self,@"Transitioned from ubiquity %@ to %@",@(previousUbiquity),@(ubiquitous));
			}];
		}
    }
#endif
}

- (BOOL) isUbiquitous {
	return _ubiquityState.ubiquitous;
}

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
    return self.iCloudAvailable ? self.ubiquitousStoreURL : self.localStoreURL;
}

- (NSDictionary *) storeMetadata {
	NSError *error = nil;
	NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:self.persistentStoreURL error:&error];
	if(storeMetadata == nil) {
		FLogError(error,@"Couldn't get store metadata!");
	}
	
	return storeMetadata;
}



#pragma mark - -- Private



- (void) setSuspended:(BOOL)suspended {
	if (_suspended != suspended) {
		_suspended = suspended;
		if (_suspended) {
			dispatch_suspend(_setupQueue);
			_suspendedUbiquityState = [FSQCoreDataStackUbiquityState withState:_ubiquityState];
		}
		else {
			dispatch_resume(_setupQueue);
			_suspendedUbiquityState = nil;
		}
	}
}

// Ubiquity

@dynamic ubiquityToken;
- (void) setUbiquityToken:(id)ubiquityToken {
    if (_ubiquityState.ubiquityToken != ubiquityToken) {
		if (self.suspended) {
			_suspendedUbiquityState.ubiquityToken = ubiquityToken;
		}
		else {
			id previousToken = _ubiquityState.ubiquityToken;
			_ubiquityState.ubiquityToken = ubiquityToken;
			FSQCoreDataStackUbiquityTransition transition = ubiquityToken == nil ? FSQCoreDataStackUbiquityTransitionIdentityRemoved : FSQCoreDataStackUbiquityTransitionIdentityChanged;
			[self initializeWithUbiquityTransition:transition completionBlock:^(NSError *error) {
				if (error) {
					FLogError(error, @"Failed transistioning identity from %@ to %@",previousToken,ubiquityToken);
				}
				else {
					CoreDataLog(self,@"Transistioned identity from %@ to %@",previousToken,ubiquityToken);
				}
			}];
		}
    }
}

- (id) ubiquityToken {
	return _ubiquityState.ubiquityToken;
}

@dynamic ubiquitousContentWasDeleted;
- (void) setUbiquitousContentWasDeleted:(BOOL)ubiquitousContentWasDeleted {
	if (self.suspended) {
		_suspendedUbiquityState.ubiquitousContentWasDeleted = ubiquitousContentWasDeleted;
	}
	else {
		_ubiquityState.ubiquitousContentWasDeleted = ubiquitousContentWasDeleted;
		if (ubiquitousContentWasDeleted) {
			[self initializeWithUbiquityTransition:FSQCoreDataStackUbiquityTransitionDataReset completionBlock:^(NSError *error) {
				if (error) {
					FLogError(error, @"Error trying to reload after ubiquitous content was deleted");
				}
				else {
					FLog(@"Reloaded after ubiquitous content was deleted");
				}
			}];
		}
	}
}

@dynamic ubiquityIdentifier;
- (NSString *) ubiquityIdentifier {
    if (nil == self.ubiquityToken) {
        return nil;
    }
    NSString *tokenString = [[self.ubiquityToken description] MD5Hash];
    CoreDataLog(self,@"currentUbiquityIdentifier: %@",tokenString);
    return tokenString;
}

@dynamic iCloudAvailable;
- (BOOL) iCloudAvailable {
    BOOL iCloudAvailable = (self.ubiquityToken != nil);
    CoreDataLog(self,@"_iCloudAvailable: %@",@(iCloudAvailable));
    return iCloudAvailable;
}


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

- (NSURL *) ubiquitousStoreURL {
//    if (nil == _ubiquitousStoreURL) {
//        _ubiquitousStoreURL = [self.persistentStoresDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",self.storeName,self.ubiquityIdentifier]];
//        CoreDataLog(self,@"Ubiquitous store name: %@",[_ubiquitousStoreURL lastPathComponent]);
//    }
	NSURL *ubiquitousStoreURL = [[self.persistentStoresDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",self.storeName,self.ubiquityIdentifier]] URLByAppendingPathExtension:kFSQCoreDataStackSqliteExtension];
	CoreDataLog(self,@"Ubiquitous store name: %@",[ubiquitousStoreURL lastPathComponent]);
    return ubiquitousStoreURL;
}

@dynamic ubiquitousTransactionsDataURL;
- (NSURL *) ubiquitousTransactionsDataURL {
    NSURL *ubiquitousTransactionsDataURL = [_ubiquityContainerURL URLByAppendingPathComponent:@"CoreDataTransactions"];
    CoreDataLog(self,@"ubiquitousTransactionsDataURL: %@",ubiquitousTransactionsDataURL);
    return ubiquitousTransactionsDataURL;
}

@dynamic ubiquitousStoreOptions;
- (NSDictionary *) ubiquitousStoreOptions {
	NSFileManager *fm = [NSFileManager new];
    _ubiquityContainerURL = [fm URLForUbiquityContainerIdentifier:nil];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:_storeOptions];
    [options addEntriesFromDictionary:@{ NSPersistentStoreUbiquitousContentNameKey : _storeName, NSPersistentStoreUbiquitousContentURLKey : self.ubiquitousTransactionsDataURL }];
	return options;
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
    dispatch_release(_setupQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self.ubiquityIdentityObserver];
    if (self.applicationResumedObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.applicationResumedObserver];
    }
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
        
		
		_ubiquityState = [FSQCoreDataStackUbiquityState new];
		_ubiquityState.ubiquitous = NO;
		
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.persistentStoreCoordinator = _persistentStoreCoordinator;		
        _storeOptions = @{};
        _setupQueue = dispatch_queue_create("com.fivesquaresoftware.FSQCoreDataManager.steupQueue", NULL);
        
		
#if FSQCoreDataSupportUbiquity
		_ubiquityState.ubiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];

		// get a head start on initializing the ubiquity container if need be
		if (_ubiquityState.ubiquityToken) {
			dispatch_async(_setupQueue, ^{
				NSFileManager *fm = [NSFileManager new];
				_ubiquityContainerURL = [fm URLForUbiquityContainerIdentifier:nil];
			});
		};

        FSQWeakSelf(self_);
		
        self.ubiquityIdentityObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSUbiquityIdentityDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            CoreDataLog(self_,@"NSUbiquityIdentityDidChangeNotification: %@",note);
            self_.ubiquityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
        }];
        
	#if TARGET_OS_IPHONE
		
		self.applicationPausedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            CoreDataLog(self_,@"UIApplicationDidEnterBackgroundNotification");
			self_.suspended = YES;
        }];
		
        self.applicationResumedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            CoreDataLog(self_,@"UIApplicationDidBecomeActiveNotification");
			
			FSQCoreDataStackUbiquityTransition ubiquityTransitionMask = [_ubiquityState transitionMaskForTargetState:_suspendedUbiquityState];
			self_.ubiquityState = self_.suspendedUbiquityState;
			self_.suspended = NO;
			
			if (ubiquityTransitionMask != FSQCoreDataStackUbiquityTransitionNone) {
				[self_ initializeWithUbiquityTransition:ubiquityTransitionMask completionBlock:^(NSError *error) {
					CoreDataLog(self_, @"Reinitialized stack on app resume with transitions: %@",@(ubiquityTransitionMask));
				}];
			}
        }];
	#endif
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            CoreDataLog(self_,@"Imported ubiquitous content: %@",note);
        }];
#endif

	}
	return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%@ model: %@ storeName: %@",[super description],self.modelName,self.storeName];
}



// ========================================================================== //

#pragma mark - Stack Setup

- (void) initializeWithCompletionBlock:(void(^)(NSError *error))completionBlock {
    if (NO == self.wasInitialized) {
        self.initialized = YES;
		[self initializeWithUbiquityTransition:FSQCoreDataStackUbiquityTransitionNone completionBlock:completionBlock];
    }
}

- (void) reloadWithCompletionBlock:(void(^)(NSError *error))completionBlock {
    [self initializeWithUbiquityTransition:FSQCoreDataStackUbiquityTransitionNone completionBlock:completionBlock];
}

- (void) initializeWithUbiquityTransition:(FSQCoreDataStackUbiquityTransition)transition completionBlock:(void(^)(NSError *error))completionBlock {
//    if (nil == _migrationHandler) {
//        FLogWarn(@"Initializing a stack without a migration handler in place! This can lead to data loss when ubiquity transitions occur.");
//    }
    dispatch_async(_setupQueue, ^{
        [self _dropPersistentStore];
		__strong NSError *loadError;
        NSError *error = nil;
        [self _initializeStoresWithUbiquityTransition:transition error:&error];
		loadError = error;
        CoreDataLog(self,@"Initialization complete");
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(loadError);
            });
        }
    });
}



// ========================================================================== //

#pragma mark - Setup (Internal)

/** These must all be run on the internal queue, do not call these from the main thread. */

- (BOOL) _initializeStoresWithUbiquityTransition:(FSQCoreDataStackUbiquityTransition)transitionMask error:(NSError **)errorPtr {
    CoreDataLog(self,@"Initializing persistent store");
    FSQAssert([_persistentStoreCoordinator persistentStores].count < 1, @"Tried to load persistent stores when they are already open! %@",[_persistentStoreCoordinator persistentStores]);	


	CoreDataLog(self, @"state: %@",_ubiquityState);
	CoreDataLog(self, @"transitionMask: %@",@(transitionMask));

//	BOOL ubiquityWasEnabled = (transitionMask&FSQCoreDataStackUbiquityTransitionUbiquityEnabled) == FSQCoreDataStackUbiquityTransitionUbiquityEnabled;
//	BOOL ubiquityWasDisabled = (transitionMask&FSQCoreDataStackUbiquityTransitionUbiquityDisabled) == FSQCoreDataStackUbiquityTransitionUbiquityDisabled;
//	BOOL identityChanged = (transitionMask&FSQCoreDataStackUbiquityTransitionIdentityChanged) == FSQCoreDataStackUbiquityTransitionIdentityChanged;
//	BOOL identityRemoved = (transitionMask&FSQCoreDataStackUbiquityTransitionIdentityRemoved) == FSQCoreDataStackUbiquityTransitionIdentityRemoved;
//	BOOL dataWasReset = (transitionMask&FSQCoreDataStackUbiquityTransitionDataReset) == FSQCoreDataStackUbiquityTransitionDataReset;

	

	// This is a pretty complicated piece of logic. We need to handle not only the state of our settings, but keep in mind what transitions might be occurring. We infer transitions by seeing what files are on disk and comparing them to our state
	
	// Transition Cases:
	/*
	 1. ubiquitous NO -> YES, user wants local data in the cloud
	 2. ubiquitous YES -> NO, user wants cloud data to be local
	 3. identity A -> nil, user does not want A's data
	 4. identity A -> B, user does not want A's data, wants B's data
	 5. identity A -> reset app data, user does not want current data for A, but wants to keep using cloud
	 6. ubiquitous store fails to load when it contains live data
	 */

	BOOL loadedStore = NO;
    __block NSError *error = nil;
    NSFileManager *fm = [NSFileManager new];


	BOOL ubiquitous = self.ubiquitous;
	id ubiquityToken = self.ubiquityToken;
	NSURL *persistentStoresDirectoryURL = self.persistentStoresDirectoryURL;
//	NSString *persistentStoresDirectoryPath = [persistentStoresDirectoryURL path];
	NSURL *ubiquitousStoreURL = self.ubiquitousStoreURL;
	NSString *ubiquitousStorePath = [ubiquitousStoreURL path];
	NSURL *localStoreURL = self.localStoreURL;
	NSString *localStorePath = [localStoreURL path];
	
	BOOL localStoreFileExists = [fm fileExistsAtPath:localStorePath];
	BOOL ubiquitousStoreFileExists = [fm fileExistsAtPath:ubiquitousStorePath];
	NSMutableSet *nonMatchingUbiquitousStores = [NSMutableSet new];
	[[fm contentsOfDirectoryAtPath:[persistentStoresDirectoryURL path] error:&error] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (NO == [obj isEqualToString:ubiquitousStorePath]) {
			[nonMatchingUbiquitousStores addObject:obj];
		}
	}];
	BOOL ubiquitousStoreFilesExistsForOtherIdentities = ([nonMatchingUbiquitousStores count] > 0);
	
	
	BOOL useUbiquitousStore = ubiquitous;
	if (ubiquitous) {
		
		if (nil == ubiquityToken) { // wants ubiquity but there is no identity
			CoreDataLog(self, @"Wants ubiquity, but missing ubiquitous identity");
			
			if (ubiquitousStoreFileExists) { // case 3: user signed out, wants data reset, but our ubiquity setting is still YES, we can just correct, no error
				CoreDataLog(self, @"Found previous ubiquitous store but user signed out, removing ubiquitous store and resetting local data.");
				// reset local store
				if (NO == [self _removeFile:localStoreURL error:&error]) {
					//TODO: what to do when this fails?
				}
				// remove ubq store
				if (NO == [self _removeFile:ubiquitousStoreURL error:&error]) {
					//TODO: what to do when removing this fails, next time around it will appear visible
				}
			}
			else { // ubiquity failure of some kind, but we don't really know what.
				CoreDataLog(self, @"Unknown ubiquity error");
				// we probably don't need to do anything here, we'll just end up using the local store, but we will toss the error out so appropriate action can be taken if need be
				NSDictionary *info = @{ NSLocalizedDescriptionKey : @"Stack state is requesting ubiquity, but there is no identity." };
				NSError *unknownUbiquityError = [NSError errorWithDomain:kFSQCoreDataStackErrorDomain code:kFSQCoreDataStackErrorCodeUbiquityNotAvailable userInfo:info];
				error = unknownUbiquityError;
			}
			// set ubiquity to NO so we use local store if we come around again
			CoreDataLog(self, @"Ubiquity not available, falling back to local store");
			_ubiquityState.ubiquitous = NO;
			useUbiquitousStore = NO;
		}
		else if (ubiquitousStoreFilesExistsForOtherIdentities) { // case 4: user switched identities
			CoreDataLog(self, @"Found ubiquitous store for another identity, removing");
			// data is reset by virtue of setting up another ustore
			[nonMatchingUbiquitousStores enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
				NSURL *storeURL = [persistentStoresDirectoryURL URLByAppendingPathComponent:obj];
				CoreDataLog(self, @"Removing mismatched store: %@",storeURL);
				if (NO == [self _removeFile:storeURL error:&error]) {
					//TODO: anything to handle failure to remove other u stores?
				}
			}];
		}
		
		
		if (useUbiquitousStore) {
			// First see if we need to populate the u store with local or seed data
			if (NO == ubiquitousStoreFileExists) { // either no ubiquity change or turned ON
				if (localStoreFileExists) {// case 1: turned iCloud setting ON
					CoreDataLog(self, @"Populating ubiquitous store with local data");
					//TODO: merge local data to u store
				}
				else {
					//TODO: seed u store with seed data *if need be*. Since data is potentially coming from other devices, it can't be assumed this is needed.
				}
			}
			
			CoreDataLog(self,@"Attempting to load ubiquitous store");
			loadedStore = [self _loadUbiquitousStore:&error];
			if (loadedStore) {
			}
			else {
				CoreDataLog(self, @"Failed to load ubiquitous store, falling back to local store");
				NSError *failedToLoadUbiquitousStoreError = [NSError errorWithError:error domain:kFSQCoreDataStackErrorDomain code:kFSQCoreDataStackErrorCodeFailedToLoadUbiquitousStore localizedDescription:@"Failure trying to load ubiquitous store"];
				error = failedToLoadUbiquitousStoreError;
			}
		}
	}
	
	if (NO == loadedStore) { // either: always wanted local store, or failed to load ubiquitous store
		if (ubiquitousStoreFileExists) { // either: failed to load live u store or user switched off icloud setting
			if (useUbiquitousStore) { // case 7: failed to load ubiquitous store when it contains live data
				CoreDataLog(self, @"Failed to load ubiquitous store, ubiquitous data will overwrite local data!");
			}
			else {
				// if the u store exists default assumption regardless of ubiquity setting is case 2: user turned iCloud setting OFF
				// don't need to do anything I don't think ..
				CoreDataLog(self, @"User turned off ubiquity, copying ubiquitous data over local data.");
			}
			
			
			// copy cloud data over local
			if ([self _removeFile:self.localStoreURL error:&error]) {
				//TODO migrate cloud data to local, overwrite, remove u store
			}
			else {
				//TODO: how to handle failure to remove local store
			}
		}
		else if (NO == localStoreFileExists) {
			[self _seedStoreAtURL:localStoreURL withStoreOptions:_storeOptions error:&error];
		}

		loadedStore = [self _loadLocalStore:&error];
		if (loadedStore) {
			if (ubiquitousStoreFileExists) {
			}
		}
		else {
			// MAN, ARE WE IN TROUBLE ... this is a crash if it's not handled
			NSString *msg = [NSString stringWithFormat:@"Unable to load any peristent store for %@",self];
			NSError *seriousError = [NSError errorWithError:error domain:kFSQCoreDataStackErrorDomain code:kFSQCoreDataStackErrorCodeFailedToLoadAnyStore localizedDescription:msg];
			error = seriousError;
		}
	}
			
    if (errorPtr) {
        *errorPtr = error;
    }
	if (error) {
		_lastError = error;
	}
    
    return loadedStore;
}

- (BOOL) _loadUbiquitousStore:(NSError **)errorPtr {
    CoreDataLog(self,@"Loading ubiquitous store");
	
    BOOL success = NO;
    NSError *error = nil;
    _ubiquitousStore = [self _openStoreAtURL:self.ubiquitousStoreURL options:self.ubiquitousStoreOptions error:&error];
    success = (_ubiquitousStore != nil);
    
    if (success) {
        [NSFileCoordinator addFilePresenter:self];
        CoreDataLog(self,@"..loaded ubiquitous store");
    }
    else {
        FLogError(error, @"Could not load ubiquitous store!");
        //TODO: set ubiquity to NO
        
        if (*errorPtr) {
            *errorPtr = error;
        }
    }
	
    return success;
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
    if (_ubiquitousStore) {
        if (NO == [self _dropStore:_ubiquitousStore error:&error]) {
            FLogError(error, @"Couldn't drop ubiquitous store!");
        }
        else {
            [NSFileCoordinator removeFilePresenter:self];
            _ubiquitousStore = nil;
        }
    }
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


// ========================================================================== //

#pragma mark - NSFilePresenter

- (NSURL *) presentedItemURL {
    return self.ubiquitousTransactionsDataURL;
}

- (NSOperationQueue *) presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler {
    CoreDataLog(self,@"Deleting ubiquity container: %@", self.presentedItemURL);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		self.ubiquitousContentWasDeleted = YES;
		if (NO == self.suspended) {
			[self reloadWithCompletionBlock:^(NSError *error) {
				if (error) {
					FLogError(error, @"Error trying to reload after ubiquitous content was deleted");
				}
				else {
					FLog(@"Reloaded after ubiquitous content was deleted");
				}
			}];
		}
    });
    completionHandler(NULL);
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


