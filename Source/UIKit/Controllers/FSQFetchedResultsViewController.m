    //
//  FSQFetchedResultsViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 2/14/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsViewController.h"

#import <Foundation/Foundation.h>


#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"
#import "NSFetchedResultsController+FSQUIKit.h"

#import "FSQMacros.h"

@interface FSQFetchedResultsViewController ()
@property (nonatomic) BOOL initialized;
@property (nonatomic, strong) id persistentStoresObserver;
@property (nonatomic, strong) id ubiquitousChangesObserver;
@end


@implementation FSQFetchedResultsViewController

// ========================================================================== //

#pragma mark - Properties


- (NSManagedObjectContext *) managedObjectContext {
	if (_managedObjectContext == nil) {
		FSQSubclassResponsibility();
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
		FSQSubclassResponsibility();
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
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self.persistentStoresObserver];
    [notificationCenter removeObserver:self.ubiquitousChangesObserver];
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
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = self.fetchedResultsController.managedObjectContext.persistentStoreCoordinator;
    
    FSQWeakSelf(self_);
    self.persistentStoresObserver = [notificationCenter addObserverForName:NSPersistentStoreCoordinatorStoresDidChangeNotification object:persistentStoreCoordinator queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self_.fetchedResultsController fetch];
    }];
    self.ubiquitousChangesObserver = [notificationCenter addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:persistentStoreCoordinator queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self_.fetchedResultsController fetch];
    }];

}

- (void) viewDidUnload {
	_fetchedResultsController = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self.fetchedResultsController fetch];
	[super viewWillAppear:animated];
}



@end
