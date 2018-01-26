//
//  FSQMenuControl.h
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSQMenuItem;

enum  {
	FSQMenuSelectionStyleNone = 0,
	FSQMenuSelectionStyleDefault = 1 << 0
};
typedef NSUInteger FSQMenuSelectionStyle;

enum  {
	FSQMenuDirectionVertical = 0,
	FSQMenuDirectionHorizontal = 1 << 0
};
typedef NSUInteger FSQMenuDirection;


@interface FSQMenuControl : UIControl <UIAppearanceContainer, UIAppearance, UIScrollViewDelegate>

@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, strong) NSString *displayNameKeyPath;
@property (nonatomic) CGSize maxItemSize; 
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR; 
@property (nonatomic) FSQMenuSelectionStyle selectionStyle UI_APPEARANCE_SELECTOR; // Defaults to FSQMenuSelectionStyleDefault which has a blue background like a table cell
@property (nonatomic) NSTextAlignment itemAlignment UI_APPEARANCE_SELECTOR; // Defaults to NSTextAlignmentLeft
@property (nonatomic) FSQMenuDirection direction UI_APPEARANCE_SELECTOR;
@property (nonatomic) BOOL scrollEnabled;

@property (nonatomic) FSQMenuItem *selectedItem; // calls #setSelectedItem:animated: with animated:NO
@property (nonatomic) NSUInteger selectedIndex; // calls #setSelectedIndex:animated: with animated:NO

- (void) initialize; // Can be overridden by subclasses to perform common initialization

- (void) addRepresentedObject:(id)representedObject;
- (void) addRepresentedObjects:(NSArray *)representedObjects;
- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (FSQMenuItem *) itemAtIndex:(NSUInteger)index;
- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated;

//TODO: add removeRepresentedObject

- (void) handleTap:(UIGestureRecognizer *)recognizer; ///< Subclasses can override to customize tap handling, defaults to selecting the tapped menu item and sending UIControlEventValueChanged.


@end
