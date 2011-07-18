//
//  UIViewController+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (FSQUIKit)

/** For cases where you might have several view stacks layered on top of each other,
 *  will return the controller managing the topmost view stack.
 */
@property (nonatomic, readonly) UIViewController *topmostController;

/** When embedded in a popover, lets you get at it. Set as a dynamic association at the runtime level. */
@property (nonatomic, assign) UIPopoverController *popoverController;

- (void) dismissPopoverControllerAnimated:(BOOL)animated;

@end
