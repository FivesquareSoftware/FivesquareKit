//
//  FSQKeyboardHandler.m
//  FivesquareKit
//
//  Created by John Clayton on 5/30/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeyboardHandler.h"

#import "FSQLogging.h"
#import "FSQAsserter.h"
#import <QuartzCore/QuartzCore.h>

@interface FSQKeyboardHandler ()
@property (nonatomic, getter = isKeyboardUp) BOOL keyboardUp;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic) CGRect frame;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) UIDeviceOrientation interfaceOrientation;
@property (nonatomic, readonly) BOOL isLandscape;
@property (nonatomic, readonly) BOOL isUpsideDown;
@end

@implementation FSQKeyboardHandler

// ========================================================================== //

#pragma mark - Properties


@dynamic interfaceOrientation;
- (UIDeviceOrientation) interfaceOrientation {
	return [[UIDevice currentDevice] orientation];
}

@dynamic isLandscape;
- (BOOL) isLandscape {
	return UIDeviceOrientationIsLandscape(self.interfaceOrientation);
}

@dynamic isUpsideDown;
- (BOOL) isUpsideDown {
	return self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
}

@dynamic view;
- (UIView *) view {
	return _viewController.view;
}

@dynamic window;
- (UIWindow *) window {
	return _viewController.view.window;
}

@dynamic bounds;
- (CGRect) bounds {
	return _viewController.view.bounds;
}

@dynamic frame;
- (CGRect) frame {
	return _viewController.view.frame;
}

- (void) setFrame:(CGRect)frame {
	_viewController.view.frame = frame;
}

@dynamic center;
- (CGPoint) center {
	return _viewController.view.center;
}

@dynamic viewFrame;
- (CGRect) viewFrame {
	return self.frame;
}


// ========================================================================== //

#pragma mark - Object



- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) initialize {
}

- (void) ready {
	[self registerForKeyboardNotifications];
}

- (id) initWithViewController:(UIViewController *)aViewController {
	self = [super init];
	if (self != nil) {
		_viewController = aViewController;
		[self initialize];
		[self ready];
	}
	return self;
}

- (id) initWithCoder {
	self = [super init];
	if (self != nil) {
		[self initialize];
		[self ready];
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self != nil) {
		[self initialize];
	}
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self ready];
}


// ========================================================================== //

#pragma mark -
#pragma mark Keyboard Notifications


- (void) keyboardWillShowNotification:(NSNotification *)notification {
	
	if(_keyboardUp)
		return;
	_keyboardUp = YES;
	
	
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame;
	[(NSValue *)[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	keyboardFrame = [_viewController.view.superview convertRect:keyboardFrame fromView:nil];
	FLogDebug(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
//	FLogDebug(@"self.frame: %@",NSStringFromCGRect(self.frame));
	
	CGRect remainingSlice;
	CGRect keyboardSlice;
	CGFloat keyboardIntrusionDimension = self.isLandscape ? keyboardFrame.size.width : keyboardFrame.size.height;
//	FLogDebug(@"keyboardIntrusionDimension: %@",@(keyboardIntrusionDimension));

	CGRectEdge keyboardOriginEdge;
	switch (self.interfaceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:
			keyboardOriginEdge = CGRectMinYEdge;
			break;
		case UIDeviceOrientationLandscapeLeft:
			keyboardOriginEdge = CGRectMinXEdge;
			break;
		case UIDeviceOrientationLandscapeRight:
			keyboardOriginEdge = CGRectMaxXEdge;
			break;			
		case UIDeviceOrientationPortrait:
		default:
			keyboardOriginEdge = CGRectMaxYEdge;
			break;
	}
//	FLogDebug(@"keyboardOriginEdge: %@",@(keyboardOriginEdge));

	CGRectDivide(self.frame, &keyboardSlice, &remainingSlice, keyboardIntrusionDimension, keyboardOriginEdge);	
//	FLogDebug(@"remainingSlice: %@",NSStringFromCGRect(remainingSlice));
//	FLogDebug(@"keyboardSlice: %@",NSStringFromCGRect(keyboardSlice));
	FSQAssert(CGRectEqualToRect(keyboardSlice, keyboardFrame), @"Keyboard slice doesn't equal keyboard frame!");
	_keyboardFrame = keyboardFrame;
	
	NSTimeInterval keyboardAnimationDuration;
	[(NSValue *)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimationDuration];
	
	UIViewAnimationCurve keyboardAnimationCurve;
	[(NSValue *)[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardAnimationCurve];
	
//	[CATransaction begin];
//	[CATransaction setAnimationDuration:keyboardAnimationDuration];
//	[CATransaction setAnimationTimingFunction:[self mediaTimingFunctionForAnimationCurve:keyboardAnimationCurve]];
	
	
//	[UIView animateWithDuration:keyboardAnimationDuration delay:0 options:[self animationOptionsForAnimationCurve:keyboardAnimationCurve] animations:^{
		self.frame = remainingSlice;
//		[_viewController.view layoutIfNeeded];
		if (_transitionBlock) {
			_transitionBlock(YES);
		}
//	} completion:^(BOOL finished) {
//	}];
//	[CATransaction commit];
}

- (void) keyboardWillHideNotification:(NSNotification *)notification {
	
	if(self.keepKeyboardUp)
		return;
	NSDictionary *userInfo = [notification userInfo];
//	FLogDebug(@"userInfo: %@",userInfo);
	
	CGRect keyboardFrame;
	[(NSValue *)[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
	keyboardFrame = [_viewController.view.superview convertRect:keyboardFrame fromView:nil];
//	FLogDebug(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
//	FLogDebug(@"self.frame: %@",NSStringFromCGRect(self.frame));

	NSTimeInterval keyboardAnimationDuration;
	[(NSValue *)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimationDuration];
	
	UIViewAnimationCurve keyboardAnimationCurve;
	[(NSValue *)[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardAnimationCurve];

	CGRect newFrame = CGRectUnion(self.frame, keyboardFrame);
	FLogDebug(@"newFrame: %@", NSStringFromCGRect(newFrame));
	_keyboardFrame = CGRectZero;
	
//	[CATransaction begin];
//	[CATransaction setAnimationDuration:keyboardAnimationDuration];
//	[CATransaction setAnimationTimingFunction:[self mediaTimingFunctionForAnimationCurve:keyboardAnimationCurve]];
	
	
//	[UIView animateWithDuration:keyboardAnimationDuration delay:0 options:[self animationOptionsForAnimationCurve:keyboardAnimationCurve] animations:^{
		self.frame = newFrame;
//		[_viewController.view layoutIfNeeded];
		if (_transitionBlock) {
			_transitionBlock(NO);
		}
//	} completion:^(BOOL finished) {
//	}];
//	[CATransaction commit];
	_keyboardUp = NO;
}

- (void) keyboardDidShowNotification:(NSNotification *)notification {
}

- (CAMediaTimingFunction *) mediaTimingFunctionForAnimationCurve:(UIViewAnimationCurve)animationCurve {
	//	UIViewAnimationOptions options = 0;
	CAMediaTimingFunction *timingFunction;
	switch (animationCurve) {
		case UIViewAnimationCurveEaseIn:
			//			options |= UIViewAnimationOptionCurveEaseIn;
			timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
			break;
		case UIViewAnimationCurveEaseOut:
//			options |= UIViewAnimationOptionCurveEaseOut;
			timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
			break;
		case UIViewAnimationCurveEaseInOut:
			//			options |= UIViewAnimationOptionCurveEaseOut;
			timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
			break;
		case UIViewAnimationCurveLinear:
//			options |= UIViewAnimationOptionCurveLinear;
			timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
			break;
		default:
//			options |= UIViewAnimationOptionCurveEaseInOut;
			timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
			break;
	}
	return timingFunction;
}

- (UIViewAnimationOptions) animationOptionsForAnimationCurve:(UIViewAnimationCurve)animationCurve {
	UIViewAnimationOptions options = 0;
	switch (animationCurve) {
		case UIViewAnimationCurveEaseIn:
			options |= UIViewAnimationOptionCurveEaseIn;
			break;
		case UIViewAnimationCurveEaseOut:
			options |= UIViewAnimationOptionCurveEaseOut;
			break;
		case UIViewAnimationCurveEaseInOut:
			options |= UIViewAnimationOptionCurveEaseInOut;
			break;
		case UIViewAnimationCurveLinear:
			options |= UIViewAnimationOptionCurveLinear;
			break;
		default:
			options |= UIViewAnimationOptionCurveEaseInOut;
			break;
	}
	return options;
}


- (void) registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}


@end
