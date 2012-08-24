//
//  CALayer+FSQQuartz.m
//  FivesquareKit
//
//  Created by John Clayton on 8/24/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "CALayer+FSQQuartz.h"

@implementation FSQShadow
+ (id) withColor:(CGColorRef)color opacity:(float)opacity offset:(CGSize)offset radius:(CGFloat)radius {
	FSQShadow *shadow = [FSQShadow new];
	shadow.color = color;
	shadow.opacity = opacity;
	shadow.offset = offset;
	shadow.radius = radius;
	return shadow;
}
@end


@implementation CALayer (FSQQuartz)

- (void) setShadow:(FSQShadow *)shadow {
	self.shadowColor = shadow.color;
	self.shadowOpacity = shadow.opacity;
	self.shadowRadius = shadow.radius;
	self.shadowOffset = shadow.offset;
}


@end
