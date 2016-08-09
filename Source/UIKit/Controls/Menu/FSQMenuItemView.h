//
//  FSQMenuItemView.h
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQMenuControl.h"
@class FSQMenuItem;

@interface FSQMenuItemView : UIView <UIAppearance>

@property (nonatomic, strong) FSQMenuItem *menuItem;
@property (nonatomic, getter = isSelected) BOOL selected;

@property (nonatomic) NSTextAlignment textAlignment UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;


@property (nonatomic) UIEdgeInsets edgeInsets UI_APPEARANCE_SELECTOR;

@property (nonatomic) FSQMenuSelectionStyle selectionStyle; // A convenience shortcut for setting #selectedBackgroundView to some preset defaults

@property (nonatomic, weak) UIView *backgroundView UI_APPEARANCE_SELECTOR; 
@property (nonatomic, weak) UIView *selectedBackgroundView UI_APPEARANCE_SELECTOR; 

@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR; 
@property (nonatomic, strong) UIColor *selectedTextColor UI_APPEARANCE_SELECTOR; 


@end
