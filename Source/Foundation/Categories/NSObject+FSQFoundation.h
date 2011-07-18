//
//  NSObject+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 6/28/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (FSQFoundation)

#if (TARGET_OS_IPHONE)
+ (NSString *)className;
- (NSString *)className;
#endif

@end
