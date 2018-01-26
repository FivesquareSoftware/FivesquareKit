//
//  FSQMenuViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQMenuItem.h"

@interface FSQMenuViewController : UITableViewController


@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, strong) NSString *displayNameKeyPath;
@property (nonatomic, copy) void (^selectionHandler)(FSQMenuItem *menuItem, NSInteger index);
@property (nonatomic, strong) Class itemTableCellClass;

@property (nonatomic) FSQMenuItem *selectedItem;
@property (nonatomic) NSInteger selectedIndex; // calls #setSelectedIndex:animated: with animated = NO


- (void) addRepresentedObject:(id)representedObject;
- (void) addRepresentedObjects:(NSArray *)representedObjects;
- (void) setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;
- (FSQMenuItem *) itemAtIndex:(NSInteger)index;
- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated;


/** Override this in your subclass to custom configure a cell for an object. */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
