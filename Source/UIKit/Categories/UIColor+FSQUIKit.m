//
//  UIColor+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 3/24/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIColor+FSQUIKit.h"

#import <CoreImage/CoreImage.h>

#import "NSArray+FSQFoundation.h"

@implementation UIColor (FSQUIKit)

+ (UIColor *) colorWithDescription:(NSString *)colorDescription {
	return nil;
}

+ (UIColor *) colorWithStringRepresentation:(NSString *)stringRepresentation {
	UIColor *color = nil;
//	CIColor *coreImageColor = [CIColor colorWithString:stringRepresentation];
	NSArray *components = [stringRepresentation componentsSeparatedByString:@" "];
	if ([components count] == 4) {
		color = [UIColor colorWithRed:[(NSString *)components[0] floatValue] green:[(NSString *)components[1] floatValue] blue:[(NSString *)components[2] floatValue] alpha:[(NSString *)components[3] floatValue]];
	}
	return color;
}

- (NSString *) stringRepresentation {
	CGColorRef colorRef = self.CGColor;
	CIColor *coreImageColor = [CIColor colorWithCGColor:colorRef];
	return coreImageColor.stringRepresentation;
}

- (UIColor *) colorWithBrightnessAdjustment:(CGFloat)brightnessAdjustment {
	UIColor *adjustedColor = nil;;
	UIColor *colorInRGB;
	CGFloat components[4];

	// iOS really only uses 2 color spaces, grayscale and RGB, convert to RGB if needed
	CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
	if (model == kCGColorSpaceModelMonochrome) {
		[self getWhite:&components[0] alpha:&components[1]];
		colorInRGB = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
	}
	else {
		colorInRGB = self;
	}
	
	[colorInRGB getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];

	CGFloat adjustedRed = components[0]+brightnessAdjustment;
	if (adjustedRed < 0) {
		adjustedRed = 0;
	}
	if (adjustedRed > 1.f) {
		adjustedRed = 1.f;
	}
	
	
	CGFloat adjustedGreen = components[1]+brightnessAdjustment;
	if (adjustedGreen < 0) {
		adjustedGreen = 0;
	}
	if (adjustedGreen > 1.f) {
		adjustedGreen = 1.f;
	}

	CGFloat adjustedBlue = components[2]+brightnessAdjustment;
	if (adjustedBlue < 0) {
		adjustedBlue = 0;
	}
	if (adjustedBlue > 1.f) {
		adjustedBlue = 1.f;
	}

	adjustedColor = [UIColor colorWithRed:adjustedRed green:adjustedGreen blue:adjustedBlue alpha:components[3]];

	return adjustedColor;
}

+ (UIColor *) randomColor {
	static NSArray *colors = nil;
	static dispatch_once_t randomColorsInitToken;
	dispatch_once(&randomColorsInitToken, ^{
		colors = @[[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor orangeColor],[UIColor purpleColor],[UIColor brownColor]];
	});
	return [colors anyObject];
}

@end
