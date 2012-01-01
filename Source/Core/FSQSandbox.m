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

+ (NSString *) directoryInUserSearchPath:(NSUInteger)directoryIdentifier {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(directoryIdentifier, NSUserDomainMask, YES);
	NSString *directory = [paths lastObject];
	return directory;
}

+ (BOOL) createDirectoryInUserSearchPath:(NSUInteger)directoryIdentifier error:(NSError **)error {
	NSString *directory = [self directoryInUserSearchPath:directoryIdentifier];
	
	NSFileManager *fm = [NSFileManager new];
	BOOL created = YES;
	if(NO == [fm fileExistsAtPath:directory isDirectory:NULL]) {
		__autoreleasing NSError *localError = nil;
		created = [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:NULL error:&localError];
		FSQAssert(created, @"Could not create caches directory! %@ (%@)",[localError localizedDescription],[localError userInfo]);
		if (NO == created && error) {
			*error = localError;
		}
	}
	return created;
}

@end
