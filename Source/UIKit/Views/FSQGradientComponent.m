//
//  FSQGradientComponent.m
//  FivesquareKit
//
//  Created by John Clayton on 5/26/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQGradientComponent.h"

@implementation FSQGradientComponent

@synthesize color = _color;
@synthesize location = _location;

@dynamic CGColor;
- (CGColorRef) CGColor {
	return [_color CGColor];
}

+ (id) withColor:(UIColor *)color location:(NSNumber *)location {
	FSQGradientComponent *component = [FSQGradientComponent new];
	component.color = color;
	component.location = location;
	return component;
}

- (id)valueForKey:(NSString *)key {
	return [super valueForKey:key];
}

- (id) valueForUndefinedKey:(NSString *)key {
	if ([key isEqualToString:@"CGColor"]) {
		return (__bridge id)[_color CGColor];
	}
	return [super valueForUndefinedKey:key];
}

@end
