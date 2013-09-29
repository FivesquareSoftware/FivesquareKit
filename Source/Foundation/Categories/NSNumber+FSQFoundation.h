//
//  NSNumber+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 9/26/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (FSQFoundation)

+ (BOOL) isEmpty:(NSNumber *)obj;
+ (BOOL) isNotEmpty:(NSNumber *)obj;

@end
