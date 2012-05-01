//
//  FSQCoreDataStack.m
//  FivesquareKit
//
//  Created by John Clayton on 2/8/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQCoreDataStack.h"

#import "FSQSandbox.h"
#import "FSQLogging.h"
#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"

@interface FSQCoreDataStack()

@property (nonatomic, copy, readwrite) NSString *modelName;
@property (nonatomic, copy, readwrite) NSString *storeName;
@property (nonatomic, retain, readwrite) NSURL *modelURL;

+ (NSURL *) storeURLForStoreName:(NSString *)aStoreName;
+ (NSString *) storePathForStoreName:(NSString *)aStoreName;
- (NSPersistentStore *) storeNamed:(NSString *)aStoreName;
+ (NSURL *) modelURLForName:(NSString *)aModelName;
- (void) copyDefaultDatabaseIfNeeded;

@end



@implementation FSQCoreDataStack


// ========================================================================== //

#pragma mark - Properties

@synthesize modelName=modelName_;
@synthesize storeName=storeName_;

@synthesize configurationName=configurationName_;
@synthesize storeOptions=storeOptions_;
@synthesize mergePolicy=mergePolicy_;
@synthesize copyDefaultDatabaseFromBundle=copyDefaultDatabaseFromBundle_;

@synthesize modelURL=modelURL_;
@synthesize mainContext=mainContext_;
@synthesize managedObjectModel=managedObjectModel_;
@synthesize persistentStoreCoordinator=persistentStoreCoordinator_;


- (NSURL *) modelURL {
	if(modelURL_ == nil && self.modelName) {
		modelURL_ = [[self class] modelURLForName:self.modelName];
	}
	return modelURL_;
}




// ========================================================================== //

#pragma mark - Object

- (id) initWithModelName:(NSString *)modelName persistentStore:(NSString *)storeName {
	if (storeName == nil) {
		self = nil;
		return self;
		FSQAssert(storeName != nil,@"storeName cannot be nil");
	}
	self = [super init];
	if (self != nil) {
		modelName_ = [modelName copy];
		storeName_ = storeName;
		copyDefaultDatabaseFromBundle_ = NO;
	}
	return self;
}



// ========================================================================== //

#pragma mark - Migration


- (BOOL) migrateIfNeeded:(NSError **)error {
	
	BOOL success = YES;
	
	NSDictionary *sourceMetadata;
	NSManagedObjectModel *sourceModel;
	NSManagedObjectModel *destinationModel;	
	
	@synchronized(self) {
		FSQAssert(persistentStoreCoordinator_ == NULL, @"Cannot migrate persistent store with it already open.");
		
		NSError * __autoreleasing*migrationError = NULL;
		if(error != NULL) 
			migrationError = error;
		
		
		sourceMetadata = [self storeMetadata];
		
		if(sourceMetadata == nil)
			return NO;
		
		sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
		destinationModel = [NSManagedObjectModel mergedModelFromBundles:nil];
		
		//FLog(@"Checking compatibility of %@ with %@",destinationModel,sourceMetadata);
		
		BOOL modelCompatibleWithExistingStore = [destinationModel
												 isConfiguration:nil
												 compatibleWithStoreMetadata:sourceMetadata];
		
		if (modelCompatibleWithExistingStore) {
			
			FLog(@"Compatible stores, no migration");
			
		} else {
			FLog(@"Need to migrate from %@ to %@",sourceMetadata,[destinationModel versionIdentifiers]);
			
			NSDate *start __attribute__((unused)) = [NSDate date];
			
			FLog(@"Starting migration at %@",start);
			
			
			@autoreleasepool {
				
				
				NSMappingModel *mappingModel = [
												NSMappingModel mappingModelFromBundles:nil 
												forSourceModel:sourceModel 
												destinationModel:destinationModel];
				
				if(mappingModel) {
					
					FLog(@"Using mapping model");
					
					// developer has provided a mapping model in the bundle
					
					NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
					
					migrationError = NULL;
					[self createPersistentStoreCoordinator:options error:migrationError];
					
				} else if(sourceModel) {
					
					// Can we use lightweight migration?
					NSError *mappingError = nil;
					if( [NSMappingModel inferredMappingModelForSourceModel:sourceModel destinationModel:destinationModel error:&mappingError] ) {
						
						FLog(@"Using lightweight migration");
						
						NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
												 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
												 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
						
						migrationError = NULL;
						[self createPersistentStoreCoordinator:options error:migrationError];
						
					} else {
						FLog(@"Not able to use lightweight migration %@ (%@)", [mappingError localizedDescription], [mappingError userInfo]);
					}
					
				} else {
					FLog(@"Not able to perform any kind of migration, your probably forgot to version your model.");
				}
				
				success = (migrationError == NULL);
				
				if(success) {
					FLog(@"Finished migration at %@ (%f)",[NSDate date],[start timeIntervalSinceNow]);
				} else {
					FLog(@"Migration failed %@ (%@)",[*migrationError localizedDescription],[*migrationError userInfo]);
				}
				
			}
		}				
	}
	
	return success;
}

- (NSDictionary *) storeMetadata {
	NSURL *storeURL = [[self class] storeURLForStoreName:self.modelName];
	
	if(storeURL == nil) 
		return nil;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if( ! [fm fileExistsAtPath:[storeURL path]] )
		return nil;
	
	NSError *error = nil;
	NSDictionary *storeMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
																							 URL:storeURL
																						   error:&error];
	if(storeMetadata == nil) {
		FLog(@"Couldn't get store metadata! %@ (%@)",[error localizedDescription],[error userInfo]);
	}
	
	return storeMetadata;
}





// ========================================================================== //

#pragma mark - Core Data stack setup


- (NSManagedObjectContext *) mainContext {
	@synchronized(self) {
		if (mainContext_ == nil) {
			NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
			if (coordinator != nil) {
				mainContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
				[mainContext_ setPersistentStoreCoordinator:coordinator];		
			}
		}
	}
	return mainContext_;
}

- (NSManagedObjectContext *) newChildContext {
	NSManagedObjectContext *child = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    child.parentContext = self.mainContext;
    return child;

}

- (NSManagedObjectModel *)managedObjectModel {
	@synchronized(self) {
		if(managedObjectModel_ == nil) {
			if(self.modelURL) { // will be nil if the file does not exist
				managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
			} else {
				managedObjectModel_ = [NSManagedObjectModel mergedModelFromBundles:nil];
			}
		}
	}
	return managedObjectModel_;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	@synchronized(self) {
		if (persistentStoreCoordinator_ == nil) {
			persistentStoreCoordinator_ = [self createPersistentStoreCoordinator:self.storeOptions error:NULL];
		}
	}
    return persistentStoreCoordinator_;
}

- (NSPersistentStoreCoordinator *) createPersistentStoreCoordinator:(NSDictionary *)someStoreOptions error:(NSError **)error {
	NSError __autoreleasing *storeError = nil;
	
	NSError * __autoreleasing *storeErrorPointer = &storeError;
	if(error != NULL)
		storeErrorPointer = error;
	
	if(self.copyDefaultDatabaseFromBundle) {
		[self copyDefaultDatabaseIfNeeded];
	}
	
	NSPersistentStoreCoordinator *aPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	
	NSURL *storeURL = [[self class] storeURLForStoreName:self.storeName];
	
	NSPersistentStore *persistentStore = [aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
																				   configuration:configurationName_
																							 URL:storeURL 
																						 options:someStoreOptions
																						   error:storeErrorPointer];
	if ( persistentStore == nil ) {
		if(storeError) {
			FSQAssert(NO, @"Error adding store %@, %@", [storeError localizedDescription], [storeError userInfo]);
		} else {
			FSQAssert(NO, @"Unknown error adding store: %@",storeURL);
		}
	}
	
	return aPersistentStoreCoordinator;
}


// ========================================================================== //

#pragma mark - Helpers


+ (NSURL *) storeURLForStoreName:(NSString *)aStoreName {
	NSString *storePath = [self storePathForStoreName:aStoreName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
	return storeURL;
}

+ (NSString *) storePathForStoreName:(NSString *)aStoreName {
	NSString *storePath = [[self databaseDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",aStoreName]];
	return storePath;
}

- (NSPersistentStore *) storeNamed:(NSString *)aStoreName {
	NSURL *storeUrl = [[self class] storeURLForStoreName:aStoreName];
	NSPersistentStore *store = [self.persistentStoreCoordinator persistentStoreForURL:storeUrl];
	return store;
}

+ (NSString *) databaseDirectory {
	NSString *supportDir = [FSQSandbox applicationSupportDirectory];
	NSString *databaseDir = [supportDir stringByAppendingPathComponent:@"CoreData"];
	
	NSFileManager *fm = [NSFileManager new];
	if( ! [fm fileExistsAtPath:databaseDir isDirectory:NULL] ) {
		NSError *error = nil;
		BOOL created = [fm createDirectoryAtPath:databaseDir withIntermediateDirectories:YES attributes:NULL error:&error];
		FSQAssert(created, @"Could not create database directory! %@ (%@)",[error localizedDescription],[error userInfo]);
	}
	
    return databaseDir;
}

+ (NSURL *) modelURLForName:(NSString *)aModelName {
	NSString *path = [[NSBundle mainBundle] pathForResource:aModelName ofType:@"mom"];
	if (path == nil)
		path = [[NSBundle mainBundle] pathForResource:aModelName ofType:@"momd"];
	NSURL *aModelURL = [NSURL fileURLWithPath:path];
	return aModelURL;
}

- (void) copyDefaultDatabaseIfNeeded {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	
	NSString *storePath = [[self class] storePathForStoreName:self.modelName];
	NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:self.modelName ofType:@"sqlite"];
	
	@synchronized(self) {
		if (defaultStorePath && ![fileManager fileExistsAtPath:storePath]) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
}


@end
