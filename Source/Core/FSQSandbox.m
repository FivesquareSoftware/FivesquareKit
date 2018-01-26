//
//  FSQSandbox.m
//  FivesquareKit
//
//  Created by John Clayton on 1/29/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQSandbox.h"

#import "FSQAsserter.h"

@implementation FSQSandbox

+ (NSString *) documentsDirectory {
	return [self directoryInUserSearchPath:NSDocumentDirectory];
}

+ (NSString *) applicationSupportDirectory {
	return [self directoryInUserSearchPath:NSApplicationSupportDirectory];
}

+ (NSString *)cachesDirectory {
	return [self directoryInUserSearchPath:NSCachesDirectory];
}

+ (NSString *) tempDirectory {
	return NSTemporaryDirectory();
}

+ (BOOL) createDocumentsDirectory {
	NSError *error = nil;
	BOOL created = [self createDirectoryInUserSearchPath:NSDocumentDirectory error:&error];
	FSQAssert(created, @"Could not create documents directory! %@ (%@)",[error localizedDescription],[error userInfo]);
	return created;
}

+ (BOOL) createApplicationSupportDirectory {
	NSError *error = nil;
	BOOL created = [self createDirectoryInUserSearchPath:NSApplicationSupportDirectory error:&error];
	FSQAssert(created, @"Could not create application support directory! %@ (%@)",[error localizedDescription],[error userInfo]);
	return created;
}

+ (BOOL) createCachesDirectory {
	NSError *error = nil;
	BOOL created = [self createDirectoryInUserSearchPath:NSCachesDirectory error:&error];
	FSQAssert(created, @"Could not create caches directory! %@ (%@)",[error localizedDescription],[error userInfo]);
	return created;
}

+ (NSString *) directoryInUserSearchPath:(NSSearchPathDirectory)directoryIdentifier {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(directoryIdentifier, NSUserDomainMask, YES);
	NSString *directory = [paths lastObject];
	return directory;
}

+ (BOOL) createDirectoryInUserSearchPath:(NSSearchPathDirectory)directoryIdentifier error:(NSError **)error {
	NSString *directory = [self directoryInUserSearchPath:directoryIdentifier];
	NSFileManager *fm = [NSFileManager new];
	BOOL created = YES;
	if(NO == [fm fileExistsAtPath:directory isDirectory:NULL]) {
		__autoreleasing NSError *localError = nil;
		created = [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:NULL error:&localError];
		FSQAssert(created, @"Could not create caches directory! %@ (%@)",[localError localizedDescription],[localError userInfo]);
		if (error) {
			*error = localError;
		}
	}
	return created;
}

+ (unsigned long long) freeSpaceForDirectoryInUserSearchPath:(NSUInteger)directoryIdentifier {
	unsigned long long space = 0;
	NSString *directory = [self directoryInUserSearchPath:directoryIdentifier];
	NSFileManager *fm = [NSFileManager new];
	NSError *error = nil;
	NSDictionary *attributes = [fm attributesOfFileSystemForPath:directory error:&error];
	FSQAssert(attributes, @"Could not get file system attributes! %@ (%@)",[error localizedDescription],[error userInfo]);
	if (attributes) {
		space = [[attributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
	}
	return space;
}

@end
