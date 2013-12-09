//
//  NSCalendar+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 12/9/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "NSCalendar+FSQFoundation.h"

@implementation NSCalendar (FSQFoundation)

- (NSString *) naturalLanguageDurationFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
	NSDateComponents *components = [self components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:startDate toDate:endDate options:0];
	
	NSInteger days = [components day];
	NSInteger minutes = [components minute];
	NSInteger seconds = [components second];
	
	NSString *durationDescription;
	if (days > 0) {
		durationDescription = [NSString  stringWithFormat:@"%@ day%@",@(days),(days > 1 ? @"s" : @"")];
	}
	else if (minutes > 0) {
		durationDescription = [NSString  stringWithFormat:@"%@ min%@",@(minutes),(minutes > 1 ? @"s" : @"")];
	}
	else if (seconds > 0) {
		durationDescription = i18n(@"Now", @"Now Time String");
	}
	return durationDescription;
}

@end
