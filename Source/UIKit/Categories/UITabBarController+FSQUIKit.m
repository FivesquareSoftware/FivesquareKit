//
//  UITabBarController+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 9/18/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "UITabBarController+FSQUIKit.h"

@implementation UITabBarController (FSQUIKit)

- (NSUInteger) indexOfController:(UIViewController *)controller {
	NSUInteger index = [self.viewControllers indexOfObject:controller];
	return index;
}

@end
