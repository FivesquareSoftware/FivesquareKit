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


@interface FSQFetchedResultsCollectionViewController ()

@end

@implementation FSQFetchedResultsCollectionViewController


#if __has_feature(objc_default_synthesize_properties) == 0
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
#endif

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


// ========================================================================== //

#pragma mark - View Controller



- (void) viewWillAppear:(BOOL)animated {
	[self.collectionView reloadData];
	[super viewWillAppear:animated];
}

// ========================================================================== //

#pragma mark - Collection View Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.fetchedResultsController numberOfObjectsInSection:section];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self responsibility:_cmd];
	return nil;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self warn:_cmd];
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
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


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//	if(self.reordering) return;
//	if( ! self.animateTableUpdates ) return;
//	
//	self.mutatingSectionIndex = NSNotFound;
	
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
//	if(self.reordering) return;
//	if( ! self.animateTableUpdates ) return;
//	
//	
//	if(type == NSFetchedResultsChangeInsert) self.mutatingSectionIndex = sectionIndex;
//	
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex + _fetchedResultsTableSection]
//						  withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex + _fetchedResultsTableSection]
//						  withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
//	if(self.reordering) return;
//	if( ! self.animateTableUpdates ) return;
//	
//	BOOL changedSection = [[[anObject changedValues] allKeys] containsObject:[self.fetchedResultsController sectionNameKeyPath]];
//    if ( (NSFetchedResultsChangeUpdate == type) && changedSection) {
//        type = NSFetchedResultsChangeMove;
//        newIndexPath = indexPath;
//    }
//	
//	
//	NSIndexPath *tableIndexPath = [self tableIndexPathForFetchedResultsIndexPath:indexPath];
//	NSIndexPath *newTableIndexPath = [self tableIndexPathForFetchedResultsIndexPath:newIndexPath];
//	
//    switch(type) {
//			
//        case NSFetchedResultsChangeInsert:
//			if(newIndexPath.section == self.mutatingSectionIndex) break;
//            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newTableIndexPath]
//								  withRowAnimation:UITableViewRowAnimationFade];
//            break;
//			
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:tableIndexPath]
//								  withRowAnimation:UITableViewRowAnimationFade];
//            break;
//			
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[self.tableView cellForRowAtIndexPath:tableIndexPath]
//					atIndexPath:tableIndexPath];
//            break;
//			
//        case NSFetchedResultsChangeMove:
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:tableIndexPath]
//								  withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newTableIndexPath]
//								  withRowAnimation:UITableViewRowAnimationTop];
//			break;
//    }
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.collectionView cellForItemAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
			[self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
			break;
	}
	

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//	if(self.reordering) {
//		self.reordering = NO;
//		return;
//	}
//	
//	self.mutatingSectionIndex = NSNotFound;
//	
//	if( ! self.animateTableUpdates ) {
//		[self.tableView reloadData];
//	} else {
//		[self.tableView endUpdates];
//	}
//
	
}

@end
