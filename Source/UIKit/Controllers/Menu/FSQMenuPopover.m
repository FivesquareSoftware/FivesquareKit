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


+ (id) createWithMenuController:(FSQMenuViewController *)controller delegate:(id<UIPopoverControllerDelegate>)popoverDelegate {
	FSQMenuPopover *popover = [self createWithContentController:controller delegate:popoverDelegate];
	popover.menuController = controller;
	return popover;
}


// ========================================================================== //

#pragma mark - Menu 

@dynamic selectedItem;
- (void) setSelectedItem:(FSQMenuItem *)selectedItem {
	[_menuController setSelectedItem:selectedItem];
}

- (FSQMenuItem *) selectedItem {
	return _menuController.selectedItem;
}

@dynamic selectedIndex;
- (void) setSelectedIndex:(NSUInteger)selectedIndex {
	[_menuController setSelectedIndex:selectedIndex];
}

- (NSUInteger) selectedIndex {
	return _menuController.selectedIndex;
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
	[_menuController setSelectedIndex:selectedIndex animated:animated];
}

- (FSQMenuItem *) itemAtIndex:(NSUInteger)index {
	return [_menuController itemAtIndex:index];
}

- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated {
	[_menuController setSelectedItem:selectedItem animated:animated];
}

@end
