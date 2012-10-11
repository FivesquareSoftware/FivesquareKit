//
//  CALayer+FSQQuartz.h
//  FivesquareKit
//
//  Created by John Clayton on 8/24/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FSQShadow : NSObject
@property CGColorRef color;
@property float opacity;
@property CGSize offset;
@property CGFloat radius;
+ (id) withColor:(CGColorRef)color opacity:(float)opacity offset:(CGSize)offset radius:(CGFloat)radius;
@end

@interface CALayer (FSQQuartz)

- (void) setShadow:(FSQShadow *)shadow;

@end
