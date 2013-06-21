//
//  FSQGradientView.h
//  FivesquareKit
//
//  Created by John Clayton on 5/6/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "FSQGradientComponent.h"

extern NSString *kFSQGradientViewRadial;

@interface FSQGradientView : UIView

/** An array of objects conforming to <FSQGradientComponent>. Color is a CGColorRef and location is a float represented as an NSNumber. 
 *  @see [CAGradientLayer colors] and [CAGradientLayer locations]
 */
@property (nonatomic, strong) NSArray *gradientComponents UI_APPEARANCE_SELECTOR;

/** @see [CALayer cornerRadius] */
@property (nonatomic) CGFloat cornerRadius;

/** @see [CAGradientLayer startPoint] */
@property (nonatomic) CGPoint startPoint;

/** @see [CAGradientLayer endPoint] */
@property (nonatomic) CGPoint endPoint;

/** @see [CAGradientLayer type]. Though CAGradientLayer only supports axial gradients, FSQGradientView can also draw radial gradients via kFSQGradientViewRadial. */
@property(nonatomic,copy) NSString *type;

/** Subclasses can override to implement common configuration. Must call #super. */
- (void) initialize;

/** Subclasses can override to implement common code to handle the completion of view loading. Must call #super. */
- (void) ready;

@end
