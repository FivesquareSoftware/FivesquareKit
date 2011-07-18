//
//  NSFileManager+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 8/9/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "NSFileManager+FSQFoundation.h"

#import "FSQAsserter.h"

@implementation NSFileManager (FSQFoundation)

- (BOOL)sizeEqualAtPath:(NSString *)path1 andPath:(NSString *)path2 {
	NSError *error = nil;

	NSDictionary *atts1 = [self attributesOfItemAtPath:path1 error:&error];
	FSQAssert(error == nil, @"Couldn't get file attributes %@",error);

	error = nil;
	NSDictionary *atts2 = [self attributesOfItemAtPath:path2 error:&error];
	FSQAssert(error == nil, @"Couldn't get file attributes %@",error);
	
	return [[atts1 objectForKey:NSFileSize] isEqual:[atts2 objectForKey:NSFileSize]];
}

@end
