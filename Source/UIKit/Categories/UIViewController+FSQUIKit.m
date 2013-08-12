    //
//  UIViewController+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "UIViewController+FSQUIKit.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>


static const NSString *kUIViewController_FSQUIKitPopoverController = @"kUIViewController_FSQUIKitPopoverController";


@implementation UIViewController (FSQUIKit)

@dynamic topmostController;
@dynamic popoverController;

- (UIViewController *) topmostController {
	if(self.presentedViewController) {
		return self.presentedViewController.topmostController;
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

- (void) transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options type:(FSQUIViewControllerTransition)transitionType completion:(void (^)(BOOL finished))completion {
	
	CGAffineTransform onDeckTransform = [self onDeckTransformForTransition:transitionType];
	CGAffineTransform resigningTransform = [self resigningTransformForTransition:transitionType];


	//HACK: to work around a bug in extended top bars where they don't redraw under the status bar when you move the view into view
	toViewController.view.hidden = YES;
	[self.view addSubview:toViewController.view];
	toViewController.view.transform = onDeckTransform;
	toViewController.view.hidden = NO;

//	toViewController.view.transform = onDeckTransform;

	
	[self transitionFromViewController:fromViewController toViewController:toViewController duration:duration options:options animations:^{
		fromViewController.view.transform = resigningTransform;
		toViewController.view.transform = CGAffineTransformIdentity;		
	} completion:completion];
}


- (CGAffineTransform) resigningTransformForTransition:(FSQUIViewControllerTransition)transition  {
	CGAffineTransform resigningTransform;
	switch (transition) {
		case FSQUIViewControllerTransitionCenterExchange:
			resigningTransform = CGAffineTransformIdentity;
			break;
		case FSQUIViewControllerTransitionExplodeAndPop:
			resigningTransform = [self centerExplodeTransform];
			break;
		case FSQUIViewControllerTransitionFlipLeftAndPop:
			resigningTransform = [self flipOutLeftTransform];
			break;
		case FSQUIViewControllerTransitionFlipRightAndPop:
			resigningTransform = [self flipOutRightTransform];
			break;
		case FSQUIViewControllerTransitionSlideLeftAndPop:
			resigningTransform = [self offscreenLeftTransform];
			break;
		case FSQUIViewControllerTransitionSlideRightAndPop:
			resigningTransform = [self offscreenRightTransform];
			break;
		case FSQUIViewControllerTransitionShrinkAndSlideLeft:
			resigningTransform = [self centerShrinkTransform];
			break;
		case FSQUIViewControllerTransitionShrinkAndSlideRight:
			resigningTransform = [self centerShrinkTransform];
			break;
		case FSQUIViewControllerTransitionSlideUp:
			resigningTransform = [self offscreenTopTransform];
			break;
		case FSQUIViewControllerTransitionSlideDown:
			resigningTransform = [self offscreenBottomTransform];
			break;
		case FSQUIViewControllerTransitionSlideLeft:
			resigningTransform = [self offscreenLeftTransform];
			break;
		case FSQUIViewControllerTransitionSlideRight:
			resigningTransform = [self offscreenRightTransform];
			break;
			
		default:
			resigningTransform = CGAffineTransformIdentity;
			break;
	}
	return resigningTransform;
}

- (CGAffineTransform) onDeckTransformForTransition:(FSQUIViewControllerTransition)transition  {
	CGAffineTransform onDeckTransform;
	switch (transition) {
		case FSQUIViewControllerTransitionCenterExchange:
			break;
		case FSQUIViewControllerTransitionExplodeAndPop:
			onDeckTransform = [self centerShrinkTransform];
			break;
		case FSQUIViewControllerTransitionFlipLeftAndPop:
			onDeckTransform = [self centerShrinkTransform];
			break;
		case FSQUIViewControllerTransitionFlipRightAndPop:
			onDeckTransform = [self centerShrinkTransform];
			break;
		case FSQUIViewControllerTransitionSlideLeftAndPop:
			onDeckTransform = [self centerShrinkTransform];
			break;
		case FSQUIViewControllerTransitionSlideRightAndPop:
			onDeckTransform = [self centerShrinkTransform];
			break;
		case FSQUIViewControllerTransitionShrinkAndSlideLeft:
			onDeckTransform = [self offscreenRightTransform];
			break;
		case FSQUIViewControllerTransitionShrinkAndSlideRight:
			onDeckTransform = [self offscreenLeftTransform];
			break;
		case FSQUIViewControllerTransitionSlideUp:
			onDeckTransform = [self offscreenBottomTransform];
			break;
		case FSQUIViewControllerTransitionSlideDown:
			onDeckTransform = [self offscreenTopTransform];
			break;
		case FSQUIViewControllerTransitionSlideLeft:
			onDeckTransform = [self offscreenRightTransform];
			break;
		case FSQUIViewControllerTransitionSlideRight:
			onDeckTransform = [self offscreenLeftTransform];
			break;
			
		default:
			onDeckTransform = CGAffineTransformIdentity;
			break;
	}
	return onDeckTransform;
}

- (CGAffineTransform) offscreenLeftTransform {
	CGAffineTransform offscreenLeftTransform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width,0);
	return offscreenLeftTransform;
}

- (CGAffineTransform) offscreenRightTransform {
	CGAffineTransform offscreenRightTransform = CGAffineTransformMakeTranslation(self.view.bounds.size.width,0);
	return offscreenRightTransform;
}

- (CGAffineTransform) offscreenTopTransform {
	CGAffineTransform offscreenTopTransform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height);
	return offscreenTopTransform;
}

- (CGAffineTransform) offscreenBottomTransform {
	CGAffineTransform offscreenBottomTransform = CGAffineTransformMakeTranslation(0, self.view.bounds.size.height);
	return offscreenBottomTransform;
}

- (CGAffineTransform) centerShrinkTransform {
	CGAffineTransform centerShrinkTransform = CGAffineTransformMakeScale(.01, .01);
	return centerShrinkTransform;
}

- (CGAffineTransform) centerExplodeTransform {
	CGAffineTransform centerExplodeTransform = CGAffineTransformMakeScale(1.9, 1.9);
	return centerExplodeTransform;
}

- (CGAffineTransform) flipOutLeftTransform {
	CGAffineTransform flipOutLeftTransform = CGAffineTransformMakeScale(1.9, 1.9);
	return flipOutLeftTransform;
}

- (CGAffineTransform) flipOutRightTransform {
	CGAffineTransform flipOutRightTransform = CGAffineTransformMakeScale(1.9, 1.9);
	return flipOutRightTransform;
}


//	CGAffineTransform resigningTransform;
//	switch () {
//		case SpotModeStream:
//			switch (toMode) {
//				case SpotModeNearby:
//					resigningTransform = offscreenTopTransform;
//					break;
//				case SpotModePicker:
//					resigningTransform = offscreenLeftTransform;
//					break;
//				case SpotModeSettings:
//					resigningTransform = offscreenRightTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//		case SpotModeNearby:
//			switch (toMode) {
//				case SpotModeStream:
//					resigningTransform = offscreenTopTransform;
//					break;
//				case SpotModePicker:
//					resigningTransform = offscreenLeftTransform;
//					break;
//				case SpotModeSettings:
//					resigningTransform = offscreenRightTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//		case SpotModePicker:
//			//			resigningTransform = offscreenRightTransform;
//			switch (toMode) {
//				case SpotModeStream:
//					resigningTransform = centerShrinkTransform;
//					break;
//				case SpotModeNearby:
//					resigningTransform = centerShrinkTransform;
//					break;
//				case SpotModeSettings:
//					resigningTransform = centerShrinkTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//		case SpotModeSettings:
//			// this should never happen
//			//			resigningTransform = offscreenLeftTransform;
//			switch (toMode) {
//				case SpotModeStream:
//					resigningTransform = offscreenLeftTransform;
//					break;
//				case SpotModeNearby:
//					resigningTransform = offscreenLeftTransform;
//					break;
//				case SpotModePicker:
//					resigningTransform = offscreenLeftTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//			
//		default:
//			resigningTransform = CGAffineTransformIdentity;
//			break;
//	}
//	return resigningTransform;
//}
//
//- (CGAffineTransform) onDeckTransformToMode:(SpotMode)toMode fromMode:(SpotMode)fromMode {
//	CGAffineTransform onDeckTransform;
//	
//	switch (fromMode) {
//		case SpotModeStream:
//			switch (toMode) {
//				case SpotModeNearby:
//					onDeckTransform = offscreenBottomTransform;
//					break;
//				case SpotModePicker:
//					onDeckTransform = centerShrinkTransform;
//					break;
//				case SpotModeSettings:
//					onDeckTransform = offscreenLeftTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//		case SpotModeNearby:
//			switch (toMode) {
//				case SpotModeStream:
//					onDeckTransform = offscreenBottomTransform;
//					break;
//				case SpotModePicker:
//					onDeckTransform = centerShrinkTransform;
//					break;
//				case SpotModeSettings:
//					onDeckTransform = offscreenLeftTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//		case SpotModePicker:
//			//			onDeckTransform = offscreenRightTransform;
//			switch (toMode) {
//				case SpotModeStream:
//					onDeckTransform = offscreenLeftTransform;
//					break;
//				case SpotModeNearby:
//					onDeckTransform = offscreenLeftTransform;
//					break;
//				case SpotModeSettings:
//					onDeckTransform = offscreenLeftTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//		case SpotModeSettings:
//			//			onDeckTransform = offscreenLeftTransform;
//			switch (toMode) {
//				case SpotModeStream:
//					onDeckTransform = offscreenRightTransform;
//					break;
//				case SpotModeNearby:
//					onDeckTransform = offscreenRightTransform;
//					break;
//				case SpotModePicker:
//					onDeckTransform = centerShrinkTransform;
//					break;
//					
//				default:
//					break;
//			}
//			break;
//			
//		default:
//			onDeckTransform = CGAffineTransformIdentity;
//			break;
//	}
//	return onDeckTransform;
//}
//

@end
