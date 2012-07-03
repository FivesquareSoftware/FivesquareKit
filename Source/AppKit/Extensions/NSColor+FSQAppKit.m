//
//  NSColor+FSQAppKit.m
//  FivesquareKit
//
//  Created by John Clayton on 6/8/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSColor+FSQAppKit.h"

@implementation NSColor (FSQAppKit)

#ifndef __MAC_10_8
@dynamic CGColor;
- (CGColorRef) CGColor {
	CGColorSpaceRef colorSpace = self.colorSpace.CGColorSpace;
	NSColor *deviceColor = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	
	CGFloat components[4];
	[deviceColor getRed:&components[0] green:&components[1] blue:&components[2] alpha: &components[3]];
	
	CGColorRef CGColor =  CGColorCreate (colorSpace, components);
	
	return CGColor;
}
#endif

@end
