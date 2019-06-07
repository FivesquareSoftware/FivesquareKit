//
//  FSQAlertView.h
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSQAlertController : UIAlertController {
}

@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) NSError *error;



+ (instancetype) infoAlertWithTitle:(NSString *)title message:(NSString *)message;

/** Returns a simple alert view with an "OK" button. */
+ (instancetype) infoAlertWithTitle:(NSString *)title message:(NSString *)message userInfo:(nullable NSDictionary *)userInfo confirmationHandler:(nullable void (^)(void))handler;

/** Returns a simple alert view with custom button text. */
+ (instancetype) infoAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle userInfo:(nullable NSDictionary *)userInfo confirmationHandler:(nullable void (^)(void))handler;

+ (instancetype) errorAlertWithError:(NSError *)error;

+ (instancetype) errorAlertWithTitle:(NSString *)title error:(NSError *)error;

/** Returns a simple alert view with an "OK" button with the title and message derived from the supplied error object. */
+ (instancetype) errorAlertWithTitle:(NSString *)title error:(NSError *)error userInfo:(nullable NSDictionary *)userInfo confirmationHandler:(nullable void (^)(void))handler;

+ (instancetype) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message confirmationHandler:(void (^)(void))handler;

+ (instancetype) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message destructive:(BOOL)destructive confirmationHandler:(void (^)(void))handler;

/** Returns an alert with a "OK" and "Cancel" buttons. */
+ (instancetype) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message destructive:(BOOL)destructive userInfo:(nullable NSDictionary *)userInfo confirmationHandler:(void (^)(void))handler;

/** Returns an alert with a button derived from the supplied button string and a "Cancel" button. */
+ (instancetype) confirmationAlertWithTitle:(NSString *)title message:(NSString *)message button:(NSString *)buttonTitle destructive:(BOOL)destructive userInfo:(nullable NSDictionary *)userInfo confirmationHandler:(void (^)(void))handler;

- (void) showFromRootController;
- (void) showFromController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
