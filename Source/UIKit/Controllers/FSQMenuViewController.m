//
//  FSQMenuViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuViewController.h"

#import "FSQMenuItem.h"

@interface FSQMenuViewController ()
- (void) initialize;
@property (nonatomic, strong) NSMutableArray *menuItemsInternal;
@end

@implementation FSQMenuViewController

// ========================================================================== //

#pragma mark - Properties

@synthesize menuItemsInternal=menuItemsInternal_;
@synthesize selectionHandler=selectionHandler_;
@synthesize displayNameKeyPath=displayNameKeyPath_;

@dynamic menuItems;
- (NSArray *) menuItems {
	return [self.menuItemsInternal copy];
}

- (NSMutableArray *) menuItemsInternal {
	if (menuItemsInternal_ == nil) {
		menuItemsInternal_ = [NSMutableArray new];
	}
	return menuItemsInternal_;
}



// ========================================================================== //

#pragma mark - Object

- (void) initialize {
	// Common initialization
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

#pragma mark - Menu Interface

- (void) addRepresentedObject:(id)representedObject {
	FSQMenuItem *menuItem = [FSQMenuItem withRepresentedObject:representedObject];
	if (self.displayNameKeyPath) {
		menuItem.displayNameKeyPath = self.displayNameKeyPath;
	}
	[self.menuItemsInternal addObject:menuItem];
}

- (void) addRepresentedObjects:(NSArray *)representedObjects {
	for (id object in representedObjects) {
		[self addRepresentedObject:object];
	}
}


// ========================================================================== //

#pragma mark - Actions



@end
