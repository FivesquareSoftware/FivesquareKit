//
//  NSAttributedString+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 8/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSAttributedString+FSQFoundation.h"
#import "NSObject+FSQFoundation.h"

@implementation NSAttributedString (FSQFoundation)

+ (BOOL) isEmpty:(NSAttributedString *)obj {
	BOOL isEmpty = [NSObject isEmpty:obj];
	if (isEmpty) {
		return isEmpty;
	}
	return [[obj string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 1;
}

@end
