//
//  FSQFetchedResultsCollectionViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 7/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsCollectionViewController.h"

#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"
#import "NSFetchedResultsController+FSQUIKit.h"
#import "NSIndexPath+FSQFoundation.h"

#import "FSQMacros.h"
#import "FSQLogging.h"
#import "NSError+FSQFoundation.h"


#define kDebugCollectionController DEBUG && 1
#define CollectionLog(frmt, ...) FLogMarkIf(kDebugCollectionController, ([NSString stringWithFormat:@"F-COLLECTION.%@",self.title]) , frmt, ##__VA_ARGS__)


@interface FSQFetchedResultsCollectionViewController ()
@property (nonatomic) BOOL initialized;
@property (nonatomic) BOOL shouldReloadCollectionView;
@property (nonatomic, strong) id persistentStoresObserver;
@property (nonatomic, strong) id ubiquitousChangesObserver;
@property (nonatomic, strong) NSBlockOperation *collectionUpdateOperation;
@end

@implementation FSQFetchedResultsCollectionViewController


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
		_fetchedResultsController.delegate = self;
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
	_animatesCollectionViewUpdates = YES;
	_animatesItemReloads = YES;
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
		[self_.collectionView reloadData];
    }];
    self.ubiquitousChangesObserver = [notificationCenter addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:persistentStoreCoordinator queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self_.fetchedResultsController fetch];
		[self_.collectionView reloadData];
    }];
	[self configureCollectionView];
	[self.collectionView reloadData];
}

- (void) configureCollectionView {
	
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.fetchedResultsController.delegate != self) {
		self.fetchedResultsController.delegate = self;
	}
	[self.fetchedResultsController fetch];
	[self.collectionView reloadData];

}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


// ========================================================================== //

#pragma mark - Collection View Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	NSInteger numberOfSections = [self.fetchedResultsController numberOfSections];
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	NSInteger numberOfItems =  [self.fetchedResultsController numberOfObjectsInSection:section];
	return numberOfItems;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self responsibility:_cmd];
	return nil;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self warn:_cmd];
}

- (void)configureSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self warn:_cmd];
}

//
//// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;


//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath; // called when the user taps on an already-selected item in multi-select mode
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
//
//// These methods provide support for copy/paste actions on cells.
//// All three should be implemented if any are.
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender;



// ========================================================================== //

#pragma mark -  NSFetchedResultsController Delegate

#define kFSQFetchedResultsCollectionViewControllerEmptySectionBug 1


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	CollectionLog(@"%@",NSStringFromSelector(_cmd));
	if (_animatesCollectionViewUpdates) {
		_shouldReloadCollectionView = NO;
		_collectionUpdateOperation = [NSBlockOperation new];		
	}
	else {
		_shouldReloadCollectionView = YES;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//	CollectionLog(@"controller.fetchRequest:%@",controller.fetchRequest);
//	CollectionLog(@"sectionInfo:%@",sectionInfo);
//	CollectionLog(@"sectionIndex:%@",@(sectionIndex));
//	CollectionLog(@"type:%@",@(type));

	if (_shouldReloadCollectionView) {
		return;
	}

	FSQWeakSelf(self_);
	switch(type) {
		case NSFetchedResultsChangeInsert: {
			CollectionLog(@"** QUEUE INSERT SECTION ** : %@",@(sectionIndex));
			[_collectionUpdateOperation addExecutionBlock:^{
				[self_.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
			}];
			break;
		}
			
		case NSFetchedResultsChangeDelete: {
			CollectionLog(@"** QUEUE DELETE SECTION ** : %@",@(sectionIndex));
			[_collectionUpdateOperation addExecutionBlock:^{
				[self_.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
			}];
			break;
		}
			
		case NSFetchedResultsChangeUpdate: {
			CollectionLog(@"** QUEUE UPDATE SECTION ** : %@",@(sectionIndex));
			[_collectionUpdateOperation addExecutionBlock:^{
				[self_.collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
			}];
			break;
		}
			
		case NSFetchedResultsChangeMove:
			CollectionLog(@"** ??? QUEUE MOVE SECTION ** : %@",@(sectionIndex));
			break;
	}
}


//NSFetchedResultsChangeInsert = 1,
//NSFetchedResultsChangeDelete = 2,
//NSFetchedResultsChangeMove = 3,
//NSFetchedResultsChangeUpdate = 4

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	if (_shouldReloadCollectionView) {
		return;
	}
	
	//	CollectionLog(@"controller.fetchRequest:%@",controller.fetchRequest);
//	CollectionLog(@"object:%@",anObject);
//	CollectionLog(@"indexPath:%@",indexPath);
//	CollectionLog(@"type:%@",@(type));
//	CollectionLog(@"newIndexPath:%@",newIndexPath);
    
//    CollectionLog(@"changedValues: %@",[anObject changedValues]);
//    CollectionLog(@"changedValuesForCurrentEvent: %@",[anObject changedValuesForCurrentEvent]);

	
	FSQWeakSelf(self_);
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert: {
#if kFSQFetchedResultsCollectionViewControllerEmptySectionBug
			NSInteger numberOfSectionsInCollectionViewNow = [self.collectionView numberOfSections];
			if (numberOfSectionsInCollectionViewNow > 0) {
				NSInteger numberOfItemsInCollectionViewSectionNow = [self.collectionView numberOfItemsInSection:indexPath.section];
				if (numberOfItemsInCollectionViewSectionNow == 0) {
					CollectionLog(@"**** RELOAD REQUIRED (NO ITEMS IN SECTION) ****");
					_shouldReloadCollectionView = YES;
				}
				else {
					CollectionLog(@"** QUEUE INSERT CELL ** : %@",newIndexPath);
					[_collectionUpdateOperation addExecutionBlock:^{
						[self_.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
					}];
				}
			}
			else {
				CollectionLog(@"**** RELOAD REQUIRED (NO SECTIONS) ****");
				_shouldReloadCollectionView = YES;
			}
#else
			CollectionLog(@"** QUEUE INSERT CELL ** : %@",newIndexPath);
			[_collectionUpdateOperation addExecutionBlock:^{
				[self_.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
			}];
#endif
			break;
		}
			
		case NSFetchedResultsChangeDelete: {
#if kFSQFetchedResultsCollectionViewControllerEmptySectionBug
			NSInteger numberOfItemsInCollectionViewSectionNow = [self.collectionView numberOfItemsInSection:indexPath.section];
			if (numberOfItemsInCollectionViewSectionNow == 1) {
				CollectionLog(@"**** RELOAD REQUIRED (NO ITEMS IN SECTION ON UPDATE) ****");
				_shouldReloadCollectionView = YES;
			}
			else {
				CollectionLog(@"** QUEUE DELETE CELL ** : %@",indexPath);
				[_collectionUpdateOperation addExecutionBlock:^{
					[self_.collectionView deleteItemsAtIndexPaths:@[indexPath]];
				}];

			}
#else
			CollectionLog(@"** QUEUE DELETE CELL ** : %@",indexPath);
			[_collectionUpdateOperation addExecutionBlock:^{
				[self_.collectionView deleteItemsAtIndexPaths:@[indexPath]];
			}];
#endif
			break;
		}
			
		case NSFetchedResultsChangeUpdate: {
#if kFSQFetchedResultsCollectionViewControllerEmptySectionBug
			// It seems the controller is sending us an update for the first insertion .. wtf?
			NSInteger numberOfItemsInCollectionViewSectionNow = [self.collectionView numberOfItemsInSection:indexPath.section];
			if (numberOfItemsInCollectionViewSectionNow == 0) {
				CollectionLog(@"**** RELOAD REQUIRED (NO ITEMS IN SECTION) ****");
				_shouldReloadCollectionView = YES;
			}
			else {
				CollectionLog(@"** QUEUE UPDATE CELL ** : %@",indexPath);
				if (_animatesItemReloads) {
					[_collectionUpdateOperation addExecutionBlock:^{
//						dispatch_async(dispatch_get_main_queue(), ^{
//							[UIView setAnimationsEnabled:NO];
							[self_.collectionView reloadItemsAtIndexPaths:@[indexPath]];
//							[UIView setAnimationsEnabled:YES];
//						});
					}];
				}
			}
#else
			CollectionLog(@"** QUEUE UPDATE CELL ** : %@",indexPath);
			if (_animatesItemReloads) {
				[_collectionUpdateOperation addExecutionBlock:^{
//					dispatch_async(dispatch_get_main_queue(), ^{
//						[UIView setAnimationsEnabled:NO];
						[self_.collectionView reloadItemsAtIndexPaths:@[indexPath]];
//						[UIView setAnimationsEnabled:YES];
//					});
				}];
			}
#endif
			break;
		}
			
			
		case NSFetchedResultsChangeMove:
			CollectionLog(@"** QUEUE MOVE CELL ** : %@ -> %@",indexPath,newIndexPath);
			[_collectionUpdateOperation addExecutionBlock:^{
				[self_.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
			}];
			break;
	}

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (_shouldReloadCollectionView) {
		[self.collectionView reloadData];
		CollectionLog(@"Reloaded collection view data");
		return;
	}
	NSUInteger numberOfUpdates = [_collectionUpdateOperation.executionBlocks count];
	@try {
		[self.collectionView performBatchUpdates:^{
			[_collectionUpdateOperation start];
		} completion:^(BOOL finished) {
			_collectionUpdateOperation = nil;
			if (finished) {
				CollectionLog(@"Completed %@ updates",@(numberOfUpdates));
			}
			else {
				CollectionLog(@"Failed to complete %@ updates",@(numberOfUpdates));
			}
		}];
	}
	@catch (NSException *exception) {
		FLogError([NSError errorWithException:exception], @"Failed while trying to animate collection view updates, ** RELOADING **");
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.collectionViewLayout invalidateLayout];
			[self.collectionView reloadData];
		});
	}
}

@end

