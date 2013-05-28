//
//  UIViewController+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FSQUIViewControllerTransition) {
	FSQUIViewControllerTransitionCenterExchange,
	FSQUIViewControllerTransitionExplodeAndPop,
	FSQUIViewControllerTransitionFlipLeftAndPop,
	FSQUIViewControllerTransitionFlipRightAndPop,
	FSQUIViewControllerTransitionSlideLeftAndPop,
	FSQUIViewControllerTransitionSlideRightAndPop,
	FSQUIViewControllerTransitionShrinkAndSlideLeft,
	FSQUIViewControllerTransitionShrinkAndSlideRight,
	FSQUIViewControllerTransitionSlideUp,
	FSQUIViewControllerTransitionSlideDown,
	FSQUIViewControllerTransitionSlideLeft,
	FSQUIViewControllerTransitionSlideRight
};


@interface UIViewController (FSQUIKit)

/** For cases where you might have several view stacks layered on top of each other,
 *  will return the controller managing the topmost view stack.
 */
@property (nonatomic, readonly) UIViewController *topmostController;

/** When embedded in a popover, lets you get at it. Set as a dynamic association at the runtime level. */
@property (nonatomic, assign) UIPopoverController *popoverController;

/** Allows for the programmatic dismissal of an associated popover controller. */
- (void) dismissPopoverControllerAnimated:(BOOL)animated;

/** Allows for some pre-defined canned VC transitions. Don't pass any of the system defined ones in the options. */
- (void) transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options type:(FSQUIViewControllerTransition)transitionType completion:(void (^)(BOOL))completion;

@end
