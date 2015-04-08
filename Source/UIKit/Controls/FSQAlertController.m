//
//  FSQAlertView.m
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQAlertController.h"

#import "FSQAsserter.h"
#import "UIViewController+FSQUIKit.h"


@interface FSQAlertController ()
@property (nonatomic, copy) void(^dismissHandler)(FSQAlertController *alertView, NSInteger buttonIndex);
@end



@implementation FSQAlertController


+ (FSQAlertController *) infoAlertWithTitle:(NSString *)title message:(NSString *)message {
	return [self infoAlertWithTitle:title message:message userInfo:nil confirmationHandler:nil];
}

+ (FSQAlertController *) infoAlertWithTitle:(NSString *)title message:(NSString *)message userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler {
	return [self infoAlertWithTitle:title message:message buttonTitle:NSLocalizedString(@"OK", @"OK Button Title") userInfo:userInfo confirmationHandler:handler];
}

+ (FSQAlertController *) infoAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler {
	FSQAlertController *alertController = [FSQAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	alertController.userInfo = userInfo;
	[alertController addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		if (handler) {
			handler();
		}
	}]];
	return alertController;
}

+ (FSQAlertController *) errorAlertWithError:(NSError *)error {
	return [self errorAlertWithTitle:NSLocalizedString(@"Error", @"Error Alert Title") error:error userInfo:nil confirmationHandler:nil];
}

+ (FSQAlertController *) errorAlertWithTitle:(NSString *)title error:(NSError *)error {
	return [self errorAlertWithTitle:title error:error userInfo:nil confirmationHandler:nil];
}

/** Returns a simple alert view with an "OK" button with the title and message derived from the supplied error object. */
+ (FSQAlertController *) errorAlertWithTitle:(NSString *)title error:(NSError *)error userInfo:(NSDictionary *)aUserInfo confirmationHandler:(void (^)())handler  {
	NSError *underlyingError = [error userInfo][NSUnderlyingErrorKey];
	NSString *message;
	if (underlyingError) {
#if !defined(NS_BLOCK_ASSERTIONS) || NS_BLOCK_ASSERTIONS == 0
		message = [NSString stringWithFormat:@"%@ (%@ %@)",[error localizedDescription],@(underlyingError.code),underlyingError.localizedDescription];
#else
		message = [error localizedDescription];
#endif
	}
	else {
#if !defined(NS_BLOCK_ASSERTIONS) || NS_BLOCK_ASSERTIONS == 0
		message = [NSString stringWithFormat:@"%@ (%@)",[error localizedDescription],@(error.code)];
#else
		message = [error localizedDescription];
#endif
	}

	FSQAlertController *alertController = [FSQAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	alertController.userInfo = aUserInfo;
	alertController.error = error;
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK Button Title") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		if (handler) {
			handler();
		}
	}]];
	return alertController;
}

+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message confirmationHandler:(void (^)())handler {
	return [self confirmationAlertWithTitle:title message:message destructive:NO userInfo:nil confirmationHandler:handler];
}

+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message destructive:(BOOL)destructive confirmationHandler:(void (^)())handler {
	return [self confirmationAlertWithTitle:title message:message destructive:destructive userInfo:nil confirmationHandler:handler];
}

+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message destructive:(BOOL)destructive userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler {
	return [self confirmationAlertWithTitle:title message:message button:NSLocalizedString(@"OK", @"OK Button Title") destructive:destructive userInfo:userInfo confirmationHandler:handler];
}

+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message button:(NSString *)buttonTitle destructive:(BOOL)destructive userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler {
	FSQAlertController *alertController = [FSQAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	alertController.userInfo = userInfo;

	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:buttonTitle style:(destructive ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
		if (handler) {
			handler();
		}
	}];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
	}];

	if (destructive) {
		[alertController addAction:confirmAction];
		[alertController addAction:cancelAction];
	}
	else {
		[alertController addAction:cancelAction];
		[alertController addAction:confirmAction];
	}

	return alertController;
}

- (void) showFromRootController {
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	UIViewController *rootController = keyWindow.rootViewController;
	FSQAssert(rootController, @"Tried to present an alert controller from a nil root view controller");
	if (rootController) {
		[rootController.visibleViewController presentViewController:self animated:YES completion:^{}];
	}
}

- (void) showFromController:(UIViewController *)controller {
	NSParameterAssert(controller);
	[controller presentViewController:self animated:YES completion:^{

	}];
	return;
}

@end
