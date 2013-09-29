//
//  NSNumber+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 9/26/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "NSNumber+FSQFoundation.h"

#import "NSObject+FSQFoundation.h"

@implementation NSNumber (FSQFoundation)

+ (BOOL) isEmpty:(NSNumber *)obj {
	BOOL isEmpty = [NSObject isEmpty:obj];
	if (isEmpty) {
		return isEmpty;
	}
	return [obj intValue] ==  0;
}

+ (BOOL) isNotEmpty:(NSNumber *)obj {
	return NO == [self isEmpty:obj];
}


@end
