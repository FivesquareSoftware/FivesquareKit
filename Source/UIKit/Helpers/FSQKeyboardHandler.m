//
//  FSQKeyboardHandler.m
//  FivesquareKit
//
//  Created by John Clayton on 5/30/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeyboardHandler.h"


@interface FSQKeyboardHandler ()
@property (nonatomic,assign) BOOL keyboardUp;
- (void) registerForKeyboardNotifications;
- (void) animationsStopped:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
@end

@implementation FSQKeyboardHandler

@synthesize keyboardUp = _keyboardUp;
@synthesize keepKeyboardUp = _keepKeyboardUp;
@synthesize viewController = _viewController;

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


- (void) keyboardDidShowNotification:(NSNotification *)notification {
	
	if(_keyboardUp)
		return;
	
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardBounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
	
	CGRect keyboardFrame = [_viewController.view.superview convertRect:keyboardBounds fromView:nil];
	CGFloat deltaX = _viewController.view.frame.size.height - keyboardFrame.origin.y;
	
	CGRect newFrame = _viewController.view.frame;
	newFrame.size.height -= deltaX;
	
	[UIView beginAnimations:@"ShowingKeyboard" context:nil];
	
	_viewController.view.frame = newFrame;
	
	[UIView commitAnimations];
	
	_keyboardUp = YES;
}

- (void) keyboardWillHideNotification:(NSNotification *)notification {
	
	if(self.keepKeyboardUp)
		return;
	
	NSDictionary *userInfo = [notification userInfo];
	
	CGRect keyboardBounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardBounds];
	
	CGRect keyboardFrame = [_viewController.view.superview convertRect:keyboardBounds fromView:nil];
	CGFloat deltaX = _viewController.view.superview.frame.size.height - keyboardFrame.origin.y;
	
	NSTimeInterval keyboardAnimationDuration;
	[(NSValue *)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimationDuration];
	
	UIViewAnimationCurve keyboardAnimationCurve;
	[(NSValue *)[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardAnimationCurve];
	
	
	CGRect newFrame = _viewController.view.frame;
	newFrame.size.height += deltaX;//(keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height);
	
	[UIView beginAnimations:@"HidingKeyboard" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationsStopped:finished:context:)];
	[UIView setAnimationDuration:keyboardAnimationDuration];
	[UIView setAnimationCurve:keyboardAnimationCurve];
	
	_viewController.view.frame = newFrame;
	
	[UIView commitAnimations];		
	
	_keyboardUp = NO;
}

- (void) animationsStopped:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
    if([animationID isEqualToString:@"ShowingKeyboard"]) {
    } else if([animationID isEqualToString:@"HidingKeyboard"]) {
    }
}

- (void) registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}


@end
