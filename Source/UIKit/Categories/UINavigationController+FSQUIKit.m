//
//  UINavigationController+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 5/23/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "UINavigationController+FSQUIKit.h"

@implementation UINavigationController (FSQUIKit)

@dynamic backViewController;
- (UIViewController *) backViewController {
	if (self.viewControllers.count < 2) {
		return nil;
	}
	UIViewController *topViewController = self.topViewController;
	NSUInteger indexOfTopViewController = [self.viewControllers indexOfObject:topViewController];
	UIViewController *backViewController = nil;
	if (indexOfTopViewController != NSNotFound) {
		backViewController = self.viewControllers[indexOfTopViewController-1];
	}
	return backViewController;
}

@dynamic rootViewController;
- (UIViewController *) rootViewController {
	return [self.viewControllers firstObject];
}

- (UIViewController *) popViewControllerAnimated:(BOOL)animated completion:(void(^)())completion {
	[CATransaction begin];
	[CATransaction setCompletionBlock:completion];
	id result =[self popViewControllerAnimated:animated];
	[CATransaction commit];
	return result;
}

@end
