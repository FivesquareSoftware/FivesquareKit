//
//  FSQAlertView.m
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQAlertView.h"


@implementation FSQAlertView


@synthesize userInfo=userInfo_;



+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage {
	return [self infoAlertWithTitle:aTitle message:aMessage userInfo:nil delegate:nil];
}

+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle 
														message:aMessage 
													   delegate:aDelegate 
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Title") 
											  otherButtonTitles:nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle 
														message:aMessage 
													   delegate:aDelegate 
											  cancelButtonTitle:aButton 
											  otherButtonTitles:nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton cancellable:(BOOL)cancellable userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	
	if (!cancellable)
	{
		return [FSQAlertView infoAlertWithTitle:aTitle message:aMessage button:aButton userInfo:aUserInfo delegate:aDelegate];
	}
	
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle 
														message:aMessage 
													   delegate:aDelegate 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button Title") 
											  otherButtonTitles:aButton, nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage {
	return [self confirmationAlertWithTitle:aTitle message:aMessage userInfo:nil delegate:nil];
}

+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate {
	FSQAlertView *alertView = [[FSQAlertView alloc] initWithTitle:aTitle 
														message:aMessage 
													   delegate:aDelegate 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button Title")
											  otherButtonTitles:NSLocalizedString(@"OK", @"OK Button Title"),nil];
	alertView.userInfo = aUserInfo;
	alertView.delegate = aDelegate;
	
	return alertView;
}

@end
