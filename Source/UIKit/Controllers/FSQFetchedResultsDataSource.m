//
//  FSQFetchedResultsDataSource.m
//  FivesquareKit
//
//  Created by John Clayton on 7/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsDataSource.h"

#import "FSQMacros.h"
#import "FSQAsserter.h"
#import "NSFetchedResultsController+FSQUIKit.h"

@implementation FSQFetchedResultsDataSource


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
}


// ========================================================================== //

#pragma mark - NSFetchedResultsControllerDelegate


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	if ([_delegate respondsToSelector:_cmd]) {
		[_delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if ([_delegate respondsToSelector:_cmd]) {
		[_delegate controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
	}
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if ([_delegate respondsToSelector:_cmd]) {
		[_delegate controllerWillChangeContent:controller];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if ([_delegate respondsToSelector:_cmd]) {
		[_delegate controllerDidChangeContent:controller];
	}
}







@end
