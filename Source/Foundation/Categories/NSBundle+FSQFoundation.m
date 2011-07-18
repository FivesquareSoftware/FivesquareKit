//
//  NSBundle+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 1/29/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "NSBundle+FSQFoundation.h"


@implementation NSBundle (FSQFoundation)


- (NSInteger) versionNumber {
	NSString *bundleVersion = [self objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
	NSInteger bundleVersionNumber = [bundleVersion integerValue];
	return bundleVersionNumber;
}

@end
