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


@synthesize managedObjectContext=managedObjectContext_;
@synthesize fetchedResultsController=fetchedResultsController_;

- (NSManagedObjectContext *) managedObjectContext {
	[FSQAsserter subclass:self responsibility:_cmd];
	return nil;
}

- (NSFetchedResultsController *) fetchedResultsController {
	[FSQAsserter subclass:self responsibility:_cmd];
	return nil;
}



// ========================================================================== //

#pragma mark - Object


- (void) dealloc {
	fetchedResultsController_.delegate = nil;
	
}


// ========================================================================== //

#pragma mark - View Controller

- (void) viewWillAppear:(BOOL)animated {
	[self.fetchedResultsController fetch];
	[super viewWillAppear:animated];
}



@end
