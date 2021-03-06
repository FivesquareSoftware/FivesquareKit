//
//  FSQGradientComponent.h
//  FivesquareKit
//
//  Created by John Clayton on 5/26/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSQGradientComponent <NSObject>
@property (nonatomic, readonly) CGColorRef CGColor;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSNumber *location;
@end

@interface FSQGradientComponent : NSObject<FSQGradientComponent>
+ (id) withColor:(UIColor *)color location:(NSNumber *)location;

@end
