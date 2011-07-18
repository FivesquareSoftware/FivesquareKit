//
//  UIPopoverController+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIPopoverController (FSQUIKit)

+ (id) createWithContentController:(UIViewController *)controller delegate:(id<UIPopoverControllerDelegate>)popoverDelegate;

+ (id) createPopoverWithContentView:(UIView *)contentView;

@end
