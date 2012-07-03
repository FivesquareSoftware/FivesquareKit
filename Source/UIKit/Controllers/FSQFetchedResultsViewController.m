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

#if __has_feature(objc_default_synthesize_properties) == 0

@synthesize managedObjectContext=managedObjectContext_;
@synthesize fetchedResultsController=fetchedResultsController_;

#endif

- (NSManagedObjectContext *) managedObjectContext {
	if (managedObjectContext_ == nil) {
		[FSQAsserter subclass:self responsibility:_cmd];
	}
	return managedObjectContext_;
}

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	if (managedObjectContext_ != managedObjectContext) {
		managedObjectContext_ = managedObjectContext;
		self.fetchedResultsController = nil;
	}
}

- (NSFetchedResultsController *) fetchedResultsController {
	if (fetchedResultsController_ == nil) {
		[FSQAsserter subclass:self responsibility:_cmd];
	}
	return fetchedResultsController_;
}

- (void) setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	if (fetchedResultsController_ != fetchedResultsController) {
		fetchedResultsController_ = fetchedResultsController;
		[fetchedResultsController_ fetch];
	}
}



// ========================================================================== //

#pragma mark - Object


- (void) dealloc {
	fetchedResultsController_.delegate = nil;
}


// ========================================================================== //

#pragma mark - View Controller

- (void) viewDidUnload {
	fetchedResultsController_ = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self.fetchedResultsController fetch];
	[super viewWillAppear:animated];
}



@end
