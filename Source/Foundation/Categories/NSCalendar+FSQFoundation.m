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
	NSInteger hours = [components hour];
	NSInteger minutes = [components minute];
	NSInteger seconds = [components second];
	
	NSMutableString *durationDescription = [[NSMutableString alloc] initWithString:@""];
	if (days == 0) {
		if (hours > 0) {
			if (minutes > 0) {
				[durationDescription appendFormat:@"%@:%@ hr%@",@(hours),@(minutes),(hours > 1 ? @"s" : @"")];
			}
			else {
				[durationDescription appendFormat:@"%@ hr%@",@(hours),(hours > 1 ? @"s" : @"")];
			}

		}
		else if (minutes > 0) {
			[durationDescription appendFormat:@"%@ min%@",@(minutes),(minutes > 1 ? @"s" : @"")];
		}
		else if (seconds > 0) {
			durationDescription = [[NSMutableString alloc] initWithString:i18n(@"Now", @"Now Time String")];
		}
	}
	return durationDescription;
}

@end
