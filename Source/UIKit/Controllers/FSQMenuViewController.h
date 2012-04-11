//
//  FSQMenuViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSQMenuItem;

@interface FSQMenuViewController : UITableViewController

@property (nonatomic, strong, readonly) NSArray *menuItems;
@property (nonatomic, strong) NSString *displayNameKeyPath;
@property (nonatomic, copy) void (^selectionHandler)(FSQMenuItem *menuItem);

- (void) addRepresentedObject:(id)representedObject;
- (void) addRepresentedObjects:(NSArray *)representedObjects;

@end
