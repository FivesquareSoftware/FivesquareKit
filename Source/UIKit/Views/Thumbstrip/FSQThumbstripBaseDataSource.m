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

@synthesize fetchRequest=fetchRequest_;



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
        fetchRequest_ = fetchRequest;
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

@end
