//
//  UIColor+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 3/24/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIColor+FSQUIKit.h"

@implementation UIColor (FSQUIKit)

//- (UInt32)rgbHex {
//	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
//	
//	CGFloat r,g,b,a;
//	if (![self red:&r green:&g blue:&b alpha:&a]) return 0;
//	
//	r = MIN(MAX(self.red, 0.0f), 1.0f);
//	g = MIN(MAX(self.green, 0.0f), 1.0f);
//	b = MIN(MAX(self.blue, 0.0f), 1.0f);
//	
//	return (((int)roundf(r * 255)) << 16)
//	| (((int)roundf(g * 255)) << 8)
//	| (((int)roundf(b * 255)));
//}
//
//- (NSString *)stringFromColor {
//	return [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.red, self.green, self.blue, self.alpha];
//}
//
//- (NSString *)hexStringFromColor {
//	return [NSString stringWithFormat:@"%0.6X", self.rgbHex];
//}
//
//+ (UIColor *)colorWithString:(NSString *)stringToConvert {
//	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
//	if (![scanner scanString:@"{" intoString:NULL]) return nil;
//	const NSUInteger kMaxComponents = 4;
//	CGFloat c[kMaxComponents];
//	NSUInteger i = 0;
//	if (![scanner scanFloat:&c[i++]]) return nil;
//	while (1) {
//		if ([scanner scanString:@"}" intoString:NULL]) break;
//		if (i >= kMaxComponents) return nil;
//		if ([scanner scanString:@"," intoString:NULL]) {
//			if (![scanner scanFloat:&c[i++]]) return nil;
//		} else {
//			// either we're at the end of there's an unexpected character here
//			// both cases are error conditions
//			return nil;
//		}
//	}
//	if (![scanner isAtEnd]) return nil;
//	UIColor *color;
//	switch (i) {
//		case 2: // monochrome
//			color = [UIColor colorWithWhite:c[0] alpha:c[1]];
//			break;
//		case 4: // RGB
//			color = [UIColor colorWithRed:c[0] green:c[1] blue:c[2] alpha:c[3]];
//			break;
//		default:
//			color = nil;
//	}
//	return color;
//}
//
//#pragma mark Class methods
//
//+ (UIColor *)randomColor {
//	return [UIColor colorWithRed:(CGFloat)RAND_MAX / random()
//						   green:(CGFloat)RAND_MAX / random()
//							blue:(CGFloat)RAND_MAX / random()
//						   alpha:1.0f];
//}
//
//+ (UIColor *)colorWithRGBHex:(UInt32)hex {
//	int r = (hex >> 16) & 0xFF;
//	int g = (hex >> 8) & 0xFF;
//	int b = (hex) & 0xFF;
//	
//	return [UIColor colorWithRed:r / 255.0f
//						   green:g / 255.0f
//							blue:b / 255.0f
//						   alpha:1.0f];
//}
//
//// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
//// Skips any leading whitespace and ignores any trailing characters
//+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
//	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
//	unsigned hexNum;
//	if (![scanner scanHexInt:&hexNum]) return nil;
//	return [UIColor colorWithRGBHex:hexNum];
//}

@end
