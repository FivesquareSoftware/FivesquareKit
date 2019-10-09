//
//  UINavigationController+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 5/23/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (FSQUIKit)

@property (nonatomic, readonly) UIViewController *backViewController;
@property (nonatomic, readonly) UIViewController *rootViewController;

- (UIViewController *) popViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void) popToRootViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end
