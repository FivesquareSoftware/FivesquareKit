//
//  NSColor+FSQAppKit.h
//  FivesquareKit
//
//  Created by John Clayton on 6/8/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (FSQAppKit)

@property (nonatomic, readonly) CGColorRef CGColor CF_RETURNS_RETAINED; 
- (CGColorRef) CGColor CF_RETURNS_RETAINED;

@end
