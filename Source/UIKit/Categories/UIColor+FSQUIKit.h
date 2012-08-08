//
//  UIColor+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 3/24/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FSQUIKit)

/** Takes the result of [aColor description] (e.g. UIDeviceRGBColorSpace 0.5 0 0.5 1) and returns the represented color object. */
+ (UIColor *) colorWithDescription:(NSString *)colorDescription;

/** @returns a new color created by altering the brightness of the receiver. */
- (UIColor *) colorWithBrightnessAdjustment:(CGFloat)brightnessAdjustment;

@end
