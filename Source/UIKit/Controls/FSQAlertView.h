//
//  FSQAlertView.h
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSQAlertView : UIAlertView {
}

@property (nonatomic, strong) id userInfo;


/** @see infoAlertWithTitle:message:userInfo:delegate:. */
+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage;

/** Returns a simple alert view with an "OK" button. */
+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;

/** Returns a simple alert view with custom button text. */
+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;

/** Returns a simple alert view with custom button text and an optional cancel button. */
+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton cancellable:(BOOL)cancellable userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;

/** @see confirmationAlertWithTitle:message:userInfo:delegate:. */
+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage;

/** Returns an alert with a "OK" and "Cancel" buttons. */
+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;


@end
