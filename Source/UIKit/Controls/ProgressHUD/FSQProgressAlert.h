//
//  FSQProgressAlert.h
//  Spot
//
//  Created by John Clayton on 8/11/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FSQProgressAlertOptions) {
	FSQProgressAlertOptionsNone						= 0
	, FSQProgressAlertOptionsIndeterminate			= 1 << 0
	, FSQProgressAlertOptionsShowsCancelButton		= 1 << 1
};

typedef NS_ENUM(NSUInteger, FSQProgressAlertStyle) {
    FSQProgressAlertStyleDefault        = 0
    ,FSQProgressAlertStyleGray           = 1
};

@interface FSQProgressAlert : UIWindow

/** Whether or not a cancel button is displayed to the user. Defaults to NO, and user interaction is disallowed. When YES, the displayed cancel button's action will set #canceled = YES and dismiss the receiver. Blocks that have been invoked by on eof the run methods are responsible for checking the canceled status if they wish to be interruptible. */
@property (nonatomic, readonly) BOOL showsCancelButton; 
@property (nonatomic, readonly) BOOL indeterminate; //< Defaults to NO, a progress bar is displayed. When YES, a spinner is used instead
@property (nonatomic) NSTimeInterval minimumDisplayTime; //< Defaults to 1.3 seconds
@property (nonatomic, strong) NSString *message;
@property (nonatomic) FSQProgressAlertStyle style;

@property (nonatomic) float progress;
@property (nonatomic, readonly, getter = isCanceled) BOOL canceled;


// Class methods that use a shared instance

+ (void) runWithStatus:(NSString *)status;
+ (void) runWithStatus:(NSString *)status options:(FSQProgressAlertOptions)options;

 //< #indeterminate = YES, canCancel = NO
+ (void) runWithStatus:(NSString *)status untilDone:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock;
+ (void) runWithStatus:(NSString *)status whileProgressing:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock;
+ (void) runWithStatus:(NSString *)status executingBlock:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock options:(FSQProgressAlertOptions)options;

+ (void) setProgress:(float)progress;
+ (void) tick;

+ (void) cancel;

+ (void) dismiss;
+ (void) dismissWithError:(NSError *)error;


// Instance methods
- (void) runWithStatus:(NSString *)status executingBlock:(void(^)(FSQProgressAlert *progressAlert))block completionBlock:(void(^)())completionBlock options:(FSQProgressAlertOptions)options;
- (void) tick;

- (void) cancel;

- (void) dismiss;
- (void) dismissWithError:(NSError *)error;


@end
