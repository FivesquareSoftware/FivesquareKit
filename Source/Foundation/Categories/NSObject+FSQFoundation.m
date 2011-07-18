//
//  NSObject+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 6/28/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "NSObject+FSQFoundation.h"


@implementation NSObject (FSQFoundation)

#if (TARGET_OS_IPHONE)
+ (NSString *) className {
	return NSStringFromClass(self);
}

- (NSString *) className {
	return NSStringFromClass([self class]);
}
#endif


@end
