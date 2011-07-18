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
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return documentsDir;
}

+ (NSString *) applicationSupportDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *supportDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return supportDir;
}

+ (NSString *)cachesDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return cachesDir;
}


+ (NSString *) documentsDirectory:(BOOL)shouldCreate {
	NSString *documentsDir = [self documentsDirectory];
	if(shouldCreate) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if( ! [fm fileExistsAtPath:documentsDir isDirectory:NULL] ) {
			NSError *error = nil;
			BOOL created = [fm createDirectoryAtPath:documentsDir withIntermediateDirectories:YES attributes:NULL error:&error];
			FSQAssert(created, @"Could not create documents directory! %@ (%@)",[error localizedDescription],[error userInfo]);
		}
	}
	return documentsDir;
}

+ (NSString *) applicationSupportDirectory:(BOOL)shouldCreate {
	NSString *supportDir = [self applicationSupportDirectory];
	if(shouldCreate) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if( ! [fm fileExistsAtPath:supportDir isDirectory:NULL] ) {
			NSError *error = nil;
			BOOL created = [fm createDirectoryAtPath:supportDir withIntermediateDirectories:YES attributes:NULL error:&error];
			FSQAssert(created, @"Could not create application support directory! %@ (%@)",[error localizedDescription],[error userInfo]);
		}
	}
	return supportDir;
}

+ (NSString *) cachesDirectory:(BOOL)shouldCreate {
	NSString *cachesDir = [self cachesDirectory];
	if(shouldCreate) {
		NSFileManager *fm = [NSFileManager defaultManager];
		if( ! [fm fileExistsAtPath:cachesDir isDirectory:NULL] ) {
			NSError *error = nil;
			BOOL created = [fm createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:NULL error:&error];
			FSQAssert(created, @"Could not create caches directory! %@ (%@)",[error localizedDescription],[error userInfo]);
		}
	}
	return cachesDir;
}

@end
