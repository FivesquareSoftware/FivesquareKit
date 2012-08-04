//
//  NSColor+FSQAppKit.h
//  FivesquareKit
//
//  Created by John Clayton on 6/8/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (FSQAppKit)

#ifndef __MAC_10_8
- (id) CGColor NS_RETURNS_AUTORELEASED;
#endif
@end
