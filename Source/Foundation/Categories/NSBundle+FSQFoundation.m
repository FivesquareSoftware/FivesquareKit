//
//  NSBundle+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 1/29/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "NSBundle+FSQFoundation.h"


@implementation NSBundle (FSQFoundation)


@dynamic releaseVersionString;
- (NSString *) releaseVersionString {
	NSString *releaseVersionString = [self objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	return releaseVersionString;
}

@dynamic versionNumberString;
- (NSString *) versionNumberString {
	NSString *bundleVersion = [self objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
	return bundleVersion;
}

@dynamic versionNumber;
- (NSInteger) versionNumber {
	NSString *bundleVersion = self.versionNumberString;
	NSInteger bundleVersionNumber = [bundleVersion integerValue];
	return bundleVersionNumber;
}


@dynamic bundleDisplayName;
- (NSString *) bundleDisplayName {
	NSString *displayName = [self objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	return displayName;
}

@end
