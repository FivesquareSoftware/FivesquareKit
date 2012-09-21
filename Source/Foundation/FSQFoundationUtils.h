//
//  FSQFoundationUtils.h
//  FivesquareKit
//
//  Created by John Clayton on 9/17/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NSRange NSRangeFromCFRange(CFRange cfRange);

#if TARGET_OS_IPHONE == 0

NSString * NSStringFromCGPoint ( CGPoint point );
NSString * NSStringFromCGRect (  CGRect rect );

#endif