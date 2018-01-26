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



+ (FSQAlertController *) infoAlertWithTitle:(NSString *)title message:(NSString *)message;

/** Returns a simple alert view with an "OK" button. */
+ (FSQAlertController *) infoAlertWithTitle:(NSString *)title message:(NSString *)message userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler;

/** Returns a simple alert view with custom button text. */
+ (FSQAlertController *) infoAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler;

+ (FSQAlertController *) errorAlertWithError:(NSError *)error;

+ (FSQAlertController *) errorAlertWithTitle:(NSString *)title error:(NSError *)error;

/** Returns a simple alert view with an "OK" button with the title and message derived from the supplied error object. */
+ (FSQAlertController *) errorAlertWithTitle:(NSString *)title error:(NSError *)error userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler;

+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message confirmationHandler:(void (^)())handler;

+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message destructive:(BOOL)destructive confirmationHandler:(void (^)())handler;

/** Returns an alert with a "OK" and "Cancel" buttons. */
+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message destructive:(BOOL)destructive userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler;

/** Returns an alert with a button derived from the supplied button string and a "Cancel" button. */
+ (FSQAlertController *) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message button:(NSString *)buttonTitle destructive:(BOOL)destructive userInfo:(NSDictionary *)userInfo confirmationHandler:(void (^)())handler;

- (void) showFromRootController;
- (void) showFromController:(UIViewController *)controller;

@end
