//
//  FSQAlertView.m
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQAlertView.h"


@interface FSQAlertView ()
@property (nonatomic, copy) void(^dismissHandler)(FSQAlertView *alertView, NSInteger buttonIndex);
@end

@implementation FSQAlertView


+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage {
	return [self infoAlertWithTitle:aTitle message:aMessage userInfo:nil delegate:nil];
}

+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle  message:aMessage delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle message:aMessage delegate:aDelegate cancelButtonTitle:aButton otherButtonTitles:nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

+ (FSQAlertView *) errorAlertWithError:(NSError *)error {
	return  [self errorAlertWithTitle:NSLocalizedString(@"Error", @"Error Alert Title") error:error userInfo:nil delegate:nil];
}

+ (FSQAlertView *) errorAlertWithTitle:(NSString *)title error:(NSError *)error {
	return [self errorAlertWithTitle:title error:error userInfo:nil delegate:nil];
}

/** Returns a simple alert view with an "OK" button with the title and message derived from the supplied error object. */
+ (FSQAlertView *) errorAlertWithTitle:(NSString *)title error:(NSError *)error userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate  {
	NSError *underlyingError = [error userInfo][NSUnderlyingErrorKey];
	NSString *message;
	if (underlyingError) {
		message = [NSString stringWithFormat:@"%@ (%@ %@)",[error localizedDescription],@(underlyingError.code),underlyingError.localizedDescription];
	}
	else {
		message = [NSString stringWithFormat:@"%@ (%@)",[error localizedDescription],@(error.code)];
	}
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:title  message:message delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") otherButtonTitles:nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage {
	return [self confirmationAlertWithTitle:aTitle message:aMessage userInfo:nil delegate:nil];
}

+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle message:aMessage delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button Title") otherButtonTitles:NSLocalizedString(@"OK", @"OK Button Title"),nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle message:aMessage delegate:aDelegate cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button Title") otherButtonTitles:aButton,nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

- (void) showWithDismissHandler:(void(^)(FSQAlertView *alertView, NSInteger buttonIndex))dismissHandler {
	self.delegate = self;
	self.dismissHandler = dismissHandler;
	[self show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (self.dismissHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.dismissHandler(self,buttonIndex);
			self.dismissHandler = nil;
		});
	}
}

@end
