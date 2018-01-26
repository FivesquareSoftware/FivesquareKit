//
//  NSCalendar+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 12/9/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (FSQFoundation)

- (NSString *) naturalLanguageDurationFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

@end
