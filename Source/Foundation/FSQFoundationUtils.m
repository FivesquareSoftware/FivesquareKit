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

CFRange CFRangeFromNSRange(NSRange nsRange) {
	CFIndex location = nsRange.location == NSNotFound ? kCFNotFound : (CFIndex)nsRange.location;
	CFIndex length = (CFIndex)nsRange.length;
	CFRange range = CFRangeMake(location, length);
	return range;
}

#if TARGET_OS_IPHONE == 0

NSString * NSStringFromCGPoint ( CGPoint point ) {
	return [NSString stringWithFormat:@"{%f,%f}",point.x,point.y];
}

NSString * NSStringFromCGRect (  CGRect rect ) {
	return [NSString stringWithFormat:@"{{%f,%f},{%f,%f}}",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
	
}

#endif