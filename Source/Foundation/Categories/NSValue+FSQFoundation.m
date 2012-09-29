//
//  NSValue+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 9/20/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSValue+FSQFoundation.h"

@implementation NSValue (FSQFoundation)

#if TARGET_OS_IPHONE == 0
+ (id) valueWithCGRect:(CGRect)rect {
	return [NSValue valueWithRect:rect];
}

- (CGRect) CGRectValue {
	return [self rectValue];
}

#endif

@end
