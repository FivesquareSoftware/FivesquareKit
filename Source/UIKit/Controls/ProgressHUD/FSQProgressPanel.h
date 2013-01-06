//
//  SPProgressPanel.h
//  Spot
//
//  Created by John Clayton on 8/11/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQProgressAlert.h"

@class FSQLabel;

@interface FSQProgressPanel : UIView

@property (nonatomic, readwrite) BOOL showsCancelButton; //< Default is NO
@property (nonatomic) BOOL indeterminate; //< Default is NO, progress bar
@property (nonatomic) FSQProgressAlertStyle style;
@property (nonatomic, weak) UIActivityIndicatorView *spinner;
@property (nonatomic, weak) UIProgressView *progressBar;
@property (nonatomic, weak) FSQLabel *messageLabel;

@end
