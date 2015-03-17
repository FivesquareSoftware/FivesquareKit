//
//  FSQAlertView.h
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning Convert FSQAlertView to FSQAlertController and subclass UIALertController
@interface FSQAlertView : UIAlertView <UIAlertViewDelegate> {
}

@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) NSError *error;



/** @see infoAlertWithTitle:message:userInfo:delegate:. */
+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage;

/** Returns a simple alert view with an "OK" button. */
+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;

/** Returns a simple alert view with custom button text. */
+ (FSQAlertView *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;

/** @see  errorAlertWithError:userInfo:delegate: */
+ (FSQAlertView *) errorAlertWithError:(NSError *)error;

+ (FSQAlertView *) errorAlertWithTitle:(NSString *)title error:(NSError *)error;

/** Returns a simple alert view with an "OK" button with the title and message derived from the supplied error object. */
+ (FSQAlertView *) errorAlertWithTitle:(NSString *)title error:(NSError *)error userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;

/** @see confirmationAlertWithTitle:message:userInfo:delegate:. */
+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage;

/** Returns an alert with a "OK" and "Cancel" buttons. */
+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;

/** Returns an alert with a button derived from the supplied button string and a "Cancel" button. */
+ (FSQAlertView *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo delegate:(id<UIAlertViewDelegate>)aDelegate;


- (void) showWithDismissHandler:(void(^)(FSQAlertView *alertView, NSInteger buttonIndex))dismissHandler;

@end
