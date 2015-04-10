//
//  FSQMenuViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuViewController.h"
#import "FSQMenuViewController+Protected.h"

#import "FSQMenuItem.h"
#import "FSQAsserter.h"
#import "NSString+FSQFoundation.h"


static NSString *kFSQmenuViewControllerCell = @"FSQmenuViewControllerCell";

@interface FSQMenuViewController ()
@property (nonatomic) BOOL staticTableView;
@end

@implementation FSQMenuViewController

// ========================================================================== //

#pragma mark - Properties


@dynamic items;
- (NSArray *) items {
	return [self.itemsInternal copy];
}

- (void) setDisplayNameKeyPath:(NSString *)displayNameKeyPath {
	if (_displayNameKeyPath != displayNameKeyPath) {
		_displayNameKeyPath = displayNameKeyPath;
		[self.itemsInternal makeObjectsPerformSelector:@selector(setDisplayNameKeyPath:) withObject:_displayNameKeyPath];
	}
}

- (void) setSelectedIndex:(NSInteger)selectedIndex {
	[self setSelectedIndex:selectedIndex animated:NO];
}

@dynamic selectedItem;
- (FSQMenuItem *) selectedItem {
	return [self.itemsInternal objectAtIndex:(NSUInteger)self.selectedIndex];
}

- (void) setSelectedItem:(FSQMenuItem *)selectedItem {
	[self setSelectedItem:selectedItem animated:NO];
}



// Protected


- (NSMutableArray *) itemsInternal {
	if (_itemsInternal == nil) {
		_itemsInternal = [NSMutableArray new];
	}
	return _itemsInternal;
}



// ========================================================================== //

#pragma mark - Object

- (void) initialize {
	// Common initialization
	self.clearsSelectionOnViewWillAppear = NO;
	self.itemTableCellClass = [UITableViewCell class];
	_selectedIndex = UINT_MAX;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self initialize];
		self.tableView.dataSource = self;
		self.tableView.delegate = self;
    }
    return self;
}



// ========================================================================== //

#pragma mark - View Controller


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	_staticTableView = (self.tableView.dataSource != self);
	if (_staticTableView) {
		// Static table, extract menu items
		NSInteger numberOfRows = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0];
		for (NSInteger idx = 0; idx < numberOfRows; idx++) {
			UITableViewCell *cell = [self.tableView.dataSource tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
			FSQAssert(cell, @"Couldn't get cell from a static table to create menu item!");
			if (cell) {
				NSString *text = cell.textLabel.text;
				FSQAssert([NSString isNotEmpty:text], @"Empty text for menu item!");
				if ([NSString isNotEmpty:text]) {
					[self addRepresentedObject:text];
				}
			}
		}
		// Since are cells were preloaded, update their selection if we can
		NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:(NSInteger)_selectedIndex inSection:0];
		[self.tableView selectRowAtIndexPath:newSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
	else {
		[self.tableView registerClass:_itemTableCellClass forCellReuseIdentifier:kFSQmenuViewControllerCell];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// ========================================================================== //

#pragma mark - Table View



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_staticTableView) {
		return [super numberOfSectionsInTableView:tableView];
	}
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_staticTableView) {
		return [super tableView:tableView numberOfRowsInSection:section];
	}
	return (NSInteger)self.itemsInternal.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_staticTableView) {
		return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	}

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFSQmenuViewControllerCell forIndexPath:indexPath];

    FSQMenuItem *itemAtIndex = [self itemAtIndex:indexPath.row];
	cell.textLabel.text = itemAtIndex.displayName;
	cell.imageView.image = itemAtIndex.image;
	
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FSQSubclassWarn();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger selectedIndex = indexPath.row;
	[self setSelectedIndex:selectedIndex animated:YES];
}


// ========================================================================== //

#pragma mark - Menu Interface

- (void) addRepresentedObject:(id)representedObject {
	FSQMenuItem *menuItem = [FSQMenuItem withRepresentedObject:representedObject];
	menuItem.menu = self;
	if (self.displayNameKeyPath) {
		menuItem.displayNameKeyPath = self.displayNameKeyPath;
	}
	[self.itemsInternal addObject:menuItem];
	[self.tableView reloadData];
}

- (void) addRepresentedObjects:(NSArray *)representedObjects {
	for (id object in representedObjects) {
		[self addRepresentedObject:object];
	}
}

- (void) setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
	if (_selectedIndex != selectedIndex) {
		_selectedIndex = selectedIndex;
		if (_selectedIndex < [self.itemsInternal count]) {
			FSQMenuItem *selectedItem = [self.itemsInternal objectAtIndex:(NSUInteger)selectedIndex];
			if (_selectionHandler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.selectionHandler(selectedItem, selectedIndex);
				});
			}
			NSIndexPath *newSelectedIndexPath = [NSIndexPath indexPathForRow:(NSInteger)selectedIndex inSection:0];
			NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
			if (NO == [selectedIndexPath isEqual:newSelectedIndexPath]) {
				[self.tableView selectRowAtIndexPath:newSelectedIndexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
			}
		}
	}
}

- (FSQMenuItem *) itemAtIndex:(NSInteger)index {
	if (index >= self.itemsInternal.count) {
		return nil;
	}
	return [self.itemsInternal objectAtIndex:(NSUInteger)index];
}


- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated {
	[self.itemsInternal enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (obj == selectedItem) {
			[self setSelectedIndex:(NSInteger)idx animated:animated];
			*stop = YES;
		}
	}];
}

// ========================================================================== //

#pragma mark - Actions



@end
