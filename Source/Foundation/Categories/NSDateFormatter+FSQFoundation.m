//
//  NSDateFormatter+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 3/14/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "NSDateFormatter+FSQFoundation.h"

@implementation NSDateFormatter (FSQFoundation)

+ (NSString *) mediaTimeStringFromTimeInterval:(NSTimeInterval)seconds {
	NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:seconds];
	NSDateFormatter *timeFormatter = [NSDateFormatter new];
	if (seconds >= 60*60) {
		timeFormatter.dateFormat = @"HH:mm:ss";
	}
	else {
		timeFormatter.dateFormat = @"mm:ss";
	}
	return [timeFormatter stringFromDate:timeDate];
}

@end
