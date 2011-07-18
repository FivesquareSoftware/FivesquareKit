//
//  NSBundle+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 1/29/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSBundle (FSQFoundation)

/** Returns kCFBundleVersionKey as an integer. */ 
- (NSInteger) versionNumber;

@end
