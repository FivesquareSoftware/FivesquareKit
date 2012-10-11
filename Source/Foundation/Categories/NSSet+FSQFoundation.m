//
//  NSSet+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 9/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSSet+FSQFoundation.h"

@implementation NSSet (FSQFoundation)

+ (BOOL) isEmpty:(id)obj {
	if (nil == obj) {
		return YES;
	}
	if ([NSNull null] == obj) {
		return YES;
	}
	
	return [obj count] == 0;
}

+ (BOOL) isNotEmpty:(id)obj {
	return NO == [self isEmpty:obj];
}

@end
