//
//  FSQRadialGradientLayer.m
//  FivesquareKit
//
//  Created by John Clayton on 6/21/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQRadialGradientLayer.h"

@implementation FSQRadialGradientLayer

- (void) drawInContext:(CGContextRef)context {
	CGContextSaveGState(context);
	
//	CGContextSetBlendMode(context, kCGBlendModeSoftLight);

	CGFloat *stops = malloc(sizeof(CGFloat)*self.locations.count);
	[self.locations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		stops[idx] = [obj floatValue];
	}];
	
	CGPoint startCenter = CGPointMake(self.bounds.size.width*self.startPoint.x, self.bounds.size.height*self.startPoint.y);
	CGPoint endCenter = startCenter;
		
	CGRect bounds = self.bounds;
	CGFloat circumscribingWidth = sqrt(2) * bounds.size.width;
	CGFloat circumscribingHeight = sqrt(2) * bounds.size.height;
	CGFloat circumscribingRadius = circumscribingWidth > circumscribingHeight ? circumscribingWidth : circumscribingHeight;

	CGFloat startRadius = 0;
	CGFloat endRadius = circumscribingRadius;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)self.colors, stops);
	CGContextDrawRadialGradient(context, gradient, startCenter, 0, endCenter, endRadius, 0);
	
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
	free(stops);
	
	
	CGContextRestoreGState(context);
}


@end
