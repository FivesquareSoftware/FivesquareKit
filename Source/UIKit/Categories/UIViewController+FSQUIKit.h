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

// Are we going back in the nav controller's stack
@property (nonatomic, readonly) BOOL isDisappearingBackwards;

/** If the receiver is the nav controller's first controller. */
@property (nonatomic, readonly) BOOL isNavRootController;

/** @deprecated
 *  @see visibleViewController;
 */
@property (nonatomic, readonly) UIViewController *topmostController;

/** For cases where you might have several view stacks layered on top of each other,
 *  will return the controller managing the topmost view stack.
 */
@property (nonatomic, readonly) UIViewController *visibleViewController;

/** Allows for some pre-defined canned VC transitions. Don't pass any of the system defined ones in the options. */
- (void) transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options type:(FSQUIViewControllerTransition)transitionType completion:(void (^)(BOOL))completion;


- (CGAffineTransform) offscreenLeftTransform;
- (CGAffineTransform) offscreenRightTransform;
- (CGAffineTransform) offscreenTopTransform;
- (CGAffineTransform) offscreenBottomTransform;

@end
