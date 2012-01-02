    //
//  FSQFetchedResultsViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 2/14/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsViewController.h"


#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"
#import "NSFetchedResultsController+FSQUIKit.h"


@implementation FSQFetchedResultsViewController

// ========================================================================== //

#pragma mark - Properties


@synthesize managedObjectContext;

@dynamic fetchedResultsController;


- (NSFetchedResultsController *) fetchedResultsController {
	FSQAssert(NO, @"Implement fetchedResultsController in %@",[self className]);
	return nil;
}



// ========================================================================== //

#pragma mark - Object


- (void) dealloc {
	fetchedResultsController.delegate = nil;
	
}


// ========================================================================== //

#pragma mark - View Controller

- (void) viewWillAppear:(BOOL)animated {
	[self.fetchedResultsController fetch];
	[super viewWillAppear:animated];
}



@end
