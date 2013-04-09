//
//  NSDateFormatter+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 3/14/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (FSQFoundation)

+ (NSString *) mediaTimeStringFromTimeInterval:(NSTimeInterval)seconds;

@end
