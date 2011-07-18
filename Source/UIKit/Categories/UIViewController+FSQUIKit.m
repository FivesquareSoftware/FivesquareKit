    //
//  UIViewController+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "UIViewController+FSQUIKit.h"

#import <objc/runtime.h>


static const NSString *kUIViewController_FSQUIKitPopoverController = @"kUIViewController_FSQUIKitPopoverController";


@implementation UIViewController (FSQUIKit)

@dynamic topmostController;
@dynamic popoverController;

- (UIViewController *) topmostController {
	if(self.modalViewController) {
		return self.modalViewController.topmostController;
	}
	return self;
}

- (void) setPopoverController:(UIPopoverController *)value {
	objc_setAssociatedObject(self, &kUIViewController_FSQUIKitPopoverController, value, OBJC_ASSOCIATION_ASSIGN);
}

- (UIPopoverController *) popoverController {
	UIPopoverController *popoverController = (UIPopoverController *)objc_getAssociatedObject(self, &kUIViewController_FSQUIKitPopoverController);
	return popoverController;
}

- (void) dismissPopoverControllerAnimated:(BOOL)animated {
	if (!NSClassFromString(@"UIPopoverController"))
		return;
	
	BOOL shouldDismiss = YES;
	
	if ([self.popoverController.delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)]) {
		shouldDismiss = [self.popoverController.delegate popoverControllerShouldDismissPopover:self.popoverController];
	}
	
	if (shouldDismiss) {
		[self.popoverController dismissPopoverAnimated:animated];
		if([self.popoverController.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
			[self.popoverController.delegate popoverControllerDidDismissPopover:self.popoverController];
		}
	}	
}

@end
