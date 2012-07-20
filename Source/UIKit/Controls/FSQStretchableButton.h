//
//  FSQStretchableButton.h
//  FivesquareKit
//
//  Created by John Clayton on 4/3/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQStretchableButton : UIButton

@property (nonatomic) UIEdgeInsets capInsets; ///< Defaults to {0,2,0,2}
@property (nonatomic) CGPoint horizontalCapInsets; ///< Sets just the left and right insets, x = left, y = right
@property (nonatomic) CGPoint verticalCapInsets; ///< Sets just the top and bottom insets, x = top, y = bottom


- (void) initialize; ///< Subclasses can override to share common init

- (void) setBackgroundImage:(UIImage *)image forState:(UIControlState)state capInsets:(UIEdgeInsets)capInsets;

@end
