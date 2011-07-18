//
//  UISearchBar+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 8/18/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UISearchBar (FSQUIKit)

@property (nonatomic, assign) UIReturnKeyType returnKeyType;
@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, readonly) UIButton *cancelButton;

@end
