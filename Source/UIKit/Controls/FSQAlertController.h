//
//  FSQAlertView.h
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQAlertController : UIAlertController {
}

@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) NSError *error;



/** @see infoAlertWithTitle:message:userInfo:delegate:. */
+ (FSQAlertController *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage;

/** Returns a simple alert view with an "OK" button. */
+ (FSQAlertController *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo confirmationHandler:(void (^)())handler;

/** Returns a simple alert view with custom button text. */
+ (FSQAlertController *) infoAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage buttonTitle:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo confirmationHandler:(void (^)())handler;

/** @see  errorAlertWithError:userInfo:delegate: */
+ (FSQAlertController *) errorAlertWithError:(NSError *)error;

+ (FSQAlertController *) errorAlertWithTitle:(NSString *)title error:(NSError *)error;

/** Returns a simple alert view with an "OK" button with the title and message derived from the supplied error object. */
+ (FSQAlertController *) errorAlertWithTitle:(NSString *)title error:(NSError *)error userInfo:(NSDictionary *)aUserInfo confirmationHandler:(void (^)())handler;

/** @see confirmationAlertWithTitle:message:userInfo:delegate:. */
+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage confirmationHandler:(void (^)())handler;

/** Returns an alert with a "OK" and "Cancel" buttons. */
+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage userInfo:(NSDictionary *)aUserInfo confirmationHandler:(void (^)())handler;

/** Returns an alert with a button derived from the supplied button string and a "Cancel" button. */
+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)aTitle message:(NSString *)aMessage button:(NSString *)aButton userInfo:(NSDictionary *)aUserInfo confirmationHandler:(void (^)())handler;

- (void) showFromRootController;
- (void) showFromController:(UIViewController *)controller;

@end
