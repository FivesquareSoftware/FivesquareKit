//
//  FSQMenuPopover.m
//  FivesquareKit
//
//  Created by John Clayton on 5/7/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuPopover.h"

#import "UIPopoverController+FSQUIKit.h"
#import "FSQMenuViewController.h"

@implementation FSQMenuPopover

@synthesize menuController=menuController_;

+ (id) createWithMenuController:(FSQMenuViewController *)controller delegate:(id<UIPopoverControllerDelegate>)popoverDelegate {
	FSQMenuPopover *popover = [self createWithContentController:controller delegate:popoverDelegate];
	popover.menuController = controller;
	return popover;
}


// ========================================================================== //

#pragma mark - Menu 

@dynamic selectedItem;
- (void) setSelectedItem:(FSQMenuItem *)selectedItem {
	[menuController_ setSelectedItem:selectedItem];
}

- (FSQMenuItem *) selectedItem {
	return menuController_.selectedItem;
}

@dynamic selectedIndex;
- (void) setSelectedIndex:(NSUInteger)selectedIndex {
	[menuController_ setSelectedIndex:selectedIndex];
}

- (NSUInteger) selectedIndex {
	return menuController_.selectedIndex;
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
	[menuController_ setSelectedIndex:selectedIndex animated:animated];
}

- (FSQMenuItem *) itemAtIndex:(NSUInteger)index {
	return [menuController_ itemAtIndex:index];
}

- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated {
	[menuController_ setSelectedItem:selectedItem animated:animated];
}

@end
