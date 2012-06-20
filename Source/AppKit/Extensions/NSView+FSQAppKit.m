//
//  NSView+FSQAppKit.m
//  FivesquareKit
//
//  Created by John Clayton on 6/18/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSView+FSQAppKit.h"

#import <QuartzCore/QuartzCore.h>

#import "FSQAsserter.h"
#import "FSQLogging.h"
#import "NSColor+FSQAppKit.h"

@implementation NSView (FSQAppKit)

@dynamic backgroundColor;
- (NSColor *) backgroundColor {
	
	if (self.layer == nil) {
		FLog(@"Tried to get the background color of a view's (%@) layer but it didn't have one!",self);
		return nil;
	}
	
	CGColorRef CGColor = self.layer.backgroundColor;
	
	const CGFloat *components = CGColorGetComponents(CGColor);
	CGColorSpaceRef CGColorSpace = CGColorGetColorSpace(CGColor);
	size_t count = CGColorGetNumberOfComponents(CGColor);
	
	NSColorSpace *colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:CGColorSpace];
	NSColor *color = [NSColor colorWithColorSpace:colorSpace components:components count:(NSInteger)count];
	
	return color;
}

- (void) setBackgroundColor:(NSColor *)backgroundColor {
	if (self.wantsLayer == NO) {
		self.wantsLayer = YES;
	}
	
//	CGColorSpaceRef colorSpace = backgroundColor.colorSpace.CGColorSpace;
	NSColor *deviceColor = [backgroundColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];

	CGFloat components[4];
	[deviceColor getRed:&components[0] green:&components[1] blue:&components[2] alpha: &components[3]];

	CGColorRef CGColor =  CGColorCreate(deviceColor.colorSpace.CGColorSpace, components);

	self.layer.backgroundColor = CGColor;
	CGColorRelease(CGColor);
}

@end
