//
//  FSQThumbstripBaseDataSource.m
//  FivesquareKit
//
//  Created by John Clayton on 4/20/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQThumbstripBaseDataSource.h"
#import "FSQThumbstripBaseDataSource+Protected.h"

#import "NSFetchedResultsController+FSQUIKit.h"
#import "FSQAsserter.h"


@implementation FSQThumbstripBaseDataSource

// ========================================================================== //

#pragma mark - Properties




// Private

@dynamic managedObjectContext;
- (NSManagedObjectContext *) managedObjectContext {
	FSQSubclassResponsibility();
	return nil;
}

@dynamic fetchedResultsController;
- (NSFetchedResultsController *) fetchedResultsController {
	FSQSubclassResponsibility();
	return nil;
}


// ========================================================================== //

#pragma mark - Object

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest  {
    self = [super init];
    if (self) {
        _fetchRequest = fetchRequest;
    }
    return self;
}


// ========================================================================== //

#pragma mark - Public Interface

- (id) objectAtIndex:(NSInteger)index {
	return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}





// ========================================================================== //

#pragma mark - FSQThumbstripDataSource



- (NSInteger) numberOfItemsInthumbstripView:(FSQThumbstripView *)thumbstripView {
	NSInteger count = [self.fetchedResultsController numberOfObjectsInSection:0];
	return count;
}

- (NSArray *) thumbstripView:(FSQThumbstripView *)thumbstripView cellsForRange:(NSRange)range {
	FSQSubclassResponsibility();
	return nil;
}

- (FSQThumbstripCell *) thumbstripView:(FSQThumbstripView *)thumbstripView cellForIndex:(NSInteger)index {
	FSQSubclassResponsibility();
	return nil;
}

// ========================================================================== //

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	FSQSubclassWarn();
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	FSQSubclassWarn();
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	FSQSubclassWarn();
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	FSQSubclassWarn();
}



@end
