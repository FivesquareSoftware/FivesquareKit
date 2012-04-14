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


@implementation FSQMenuViewController

// ========================================================================== //

#pragma mark - Properties

@synthesize selectionHandler=selectionHandler_;
@synthesize displayNameKeyPath=displayNameKeyPath_;
@synthesize itemTableCellClass=itemTableCellClass_;

@dynamic items;
- (NSArray *) items {
	return [self.itemsInternal copy];
}

- (void) setDisplayNameKeyPath:(NSString *)displayNameKeyPath {
	if (displayNameKeyPath_ != displayNameKeyPath) {
		displayNameKeyPath_ = displayNameKeyPath;
		[self.itemsInternal makeObjectsPerformSelector:@selector(setDisplayNameKeyPath:) withObject:displayNameKeyPath_];
	}
}

@dynamic selectedIndex;
- (NSUInteger) selectedIndex {
	return [self.tableView indexPathForSelectedRow].row;
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex {
	[self setSelectedIndex:selectedIndex animated:NO];
}

@dynamic selectedItem;
- (FSQMenuItem *) selectedItem {
	return [self.itemsInternal objectAtIndex:self.selectedIndex];
}

- (void) setSelectedItem:(FSQMenuItem *)selectedItem {
	[self setSelectedItem:selectedItem animated:NO];
}



// Protected

@synthesize itemsInternal=itemsInternal_;

- (NSMutableArray *) itemsInternal {
	if (itemsInternal_ == nil) {
		itemsInternal_ = [NSMutableArray new];
	}
	return itemsInternal_;
}



// ========================================================================== //

#pragma mark - Object

- (void) initialize {
	// Common initialization
	self.clearsSelectionOnViewWillAppear = NO;
	self.itemTableCellClass = [UITableViewCell class];
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
    }
    return self;
}



// ========================================================================== //

#pragma mark - View Controller


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsInternal.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kFSQmenuViewControllerCell = @"FSQmenuViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFSQmenuViewControllerCell];
	if (cell == nil) {
		cell = [[self.itemTableCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFSQmenuViewControllerCell];
	}

    FSQMenuItem *itemAtIndex = [self itemAtIndex:indexPath.row];
	cell.textLabel.text = itemAtIndex.displayName;
	
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FSQSubclassWarn();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.selectionHandler) {
		FSQMenuItem *selectedItem = [self.itemsInternal objectAtIndex:indexPath.row];
		dispatch_async(dispatch_get_main_queue(), ^{
			self.selectionHandler(selectedItem);
		});
	}
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

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {		
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (FSQMenuItem *) itemAtIndex:(NSUInteger)index {
	if (index >= self.itemsInternal.count) {
		return nil;
	}
	return [self.itemsInternal objectAtIndex:index];
}


- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated {
	[self.itemsInternal enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (obj == selectedItem) {
			[self setSelectedIndex:idx animated:animated];
			*stop = YES;
		}
	}];
}

// ========================================================================== //

#pragma mark - Actions



@end
