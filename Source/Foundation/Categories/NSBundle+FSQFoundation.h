//
//  NSBundle+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 1/29/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSBundle (FSQFoundation)

@property (nonatomic, readonly) NSString *releaseVersionString;
@property (nonatomic, readonly) NSString *versionNumberString;

/** Returns kCFBundleVersionKey as an integer. */
@property (nonatomic, readonly) NSInteger versionNumber;


@property (nonatomic, readonly) NSString *bundleDisplayName;

@end
