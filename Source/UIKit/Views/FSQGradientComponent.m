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

+ (id) withColor:(UIColor *)color location:(NSNumber *)location {
	FSQGradientComponent *component = [FSQGradientComponent new];
	component.color = [color CGColor];
	component.location = location;
	return component;
}

- (id) valueForUndefinedKey:(NSString *)key {
	if ([key isEqualToString:@"color"]) {
		return (__bridge id)_color;
	}
	return [super valueForUndefinedKey:key];
}

@end
