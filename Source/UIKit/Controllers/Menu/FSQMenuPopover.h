//
//  FSQMenuPopover.h
//  FivesquareKit
//
//  Created by John Clayton on 5/7/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSQMenuViewController;
@class FSQMenuItem;

@interface FSQMenuPopover : UIPopoverController

@property (nonatomic, weak) FSQMenuViewController *menuController;

+ (id) createWithMenuController:(FSQMenuViewController *)controller delegate:(id<UIPopoverControllerDelegate>)popoverDelegate;


// Pass through methods to menu controller

@property (nonatomic) FSQMenuItem *selectedItem;
@property (nonatomic) NSInteger selectedIndex;

- (void) setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
- (FSQMenuItem *) itemAtIndex:(NSInteger)index;
- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated;


@end
