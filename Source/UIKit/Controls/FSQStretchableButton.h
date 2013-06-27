//
//  FSQStretchableButton.h
//  FivesquareKit
//
//  Created by John Clayton on 4/3/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQStretchableButton : UIButton

@property (nonatomic) UIEdgeInsets capInsets UI_APPEARANCE_SELECTOR; ///< Defaults to {0,2,0,2}
@property (nonatomic) CGPoint horizontalCapInsets; ///< Sets just the left and right insets, x = left, y = right
@property (nonatomic) CGPoint verticalCapInsets; ///< Sets just the top and bottom insets, x = top, y = bottom

@property (nonatomic) CGRect capInsetsAsRect; ///< IB cannot set an edge inset as a runtime attribute, but can set rects, stupid IB. Represent the insets using a rect as follows: {{x,y},{width,height}} => {{left,top},{right,bottom}}

- (void) initialize; ///< Subclasses can override to share common init

- (void) setBackgroundImage:(UIImage *)image forState:(UIControlState)state capInsets:(UIEdgeInsets)capInsets UI_APPEARANCE_SELECTOR;

@end
