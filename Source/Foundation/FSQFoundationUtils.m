//
//  FSQFoundationUtils.m
//  FivesquareKit
//
//  Created by John Clayton on 9/17/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFoundationUtils.h"

NSRange NSRangeFromCFRange(CFRange cfRange) {
	NSUInteger location = cfRange.location == kCFNotFound ? NSNotFound : (NSUInteger)cfRange.location;
	NSUInteger length = cfRange.length < 0 ? 0 : (NSUInteger)cfRange.length;
	NSRange range = NSMakeRange(location, length);
	return range;
}