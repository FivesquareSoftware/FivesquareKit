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

#import "FSQMacros.h"

@interface FSQFetchedResultsViewController ()
@property (nonatomic) BOOL initialized;
@property (nonatomic) BOOL readied;
@end


@implementation FSQFetchedResultsViewController

// ========================================================================== //

#pragma mark - Properties


- (NSManagedObjectContext *) managedObjectContext {
	if (_managedObjectContext == nil) {
		[FSQAsserter subclass:self responsibility:_cmd];
	}
	return _managedObjectContext;
}

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	if (_managedObjectContext != managedObjectContext) {
		_managedObjectContext = managedObjectContext;
		self.fetchedResultsController = nil;
	}
}

- (NSFetchedResultsController *) fetchedResultsController {
	if (_fetchedResultsController == nil) {
		[FSQAsserter subclass:self responsibility:_cmd];
	}
	return _fetchedResultsController;
}

- (void) setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	if (_fetchedResultsController != fetchedResultsController) {
		_fetchedResultsController = fetchedResultsController;
		[_fetchedResultsController fetch];
	}
}



// ========================================================================== //

#pragma mark - Object


- (void) dealloc {
	_fetchedResultsController.delegate = nil;
}

- (void) initialize {
	// Initialization code
	self.initialized = YES;
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

- (void) viewDidLoad {
	FSQAssert(self.initialized, @"Controller not initialized. Did you forget to call [super initialize] from %@?",self);
	[super viewDidLoad];
	[self ready];
}

- (void) ready {
	self.readied = YES;
}

- (void) viewDidUnload {
	_fetchedResultsController = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	FSQAssert(self.readied, @"Controller not readied. Did you forget to call [super ready] from %@?",self);
	[self.fetchedResultsController fetch];
	[super viewWillAppear:animated];
}



@end
