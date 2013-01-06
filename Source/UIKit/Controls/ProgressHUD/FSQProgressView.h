//
//  SPProgressView.h
//  Spot
//
//  Created by John Clayton on 8/11/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQProgressAlert.h"

@class FSQProgressPanel;

@interface FSQProgressView : UIView

@property (nonatomic, weak) FSQProgressPanel *panel;

@property (nonatomic, readwrite) BOOL showsCancelButton;
@property (nonatomic, readwrite) BOOL indeterminate;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) FSQProgressAlertStyle style;
@property (nonatomic) float progress;


//- (void) showAnimated:(BOOL)animated;
//- (void) hideAnimated:(BOOL)animated;
//- (void) hideAnimated:(BOOL)animated completionBlock:(void(^)())block;
@end
