//
//  FSQGradientView.h
//  FivesquareKit
//
//  Created by John Clayton on 5/6/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface FSQGradientView : UIView

/** An array of dictionaries each withe the keys "color" and "location". Color is a CGColorRef and location is a float represented as an NSNumber. 
 *  @see [CAGradientLayer colors] and [CAGradientLayer locations]
 */
@property (nonatomic, strong) NSArray *gradientComponents;

/** @see [CALayer cornerRadius] */
@property (nonatomic) CGFloat cornerRadius;

/** @see [CAGradientLayer startPoint] */
@property (nonatomic) CGPoint startPoint;

/** @see [CAGradientLayer endPoint] */
@property (nonatomic) CGPoint endPoint;

/** Subclasses can override to implement common configuration. Must call #super. */
- (void) initialize;

/** Subclasses can override to implement common code to handle the completion of view loading. Must call #super. */
- (void) ready;

@end
