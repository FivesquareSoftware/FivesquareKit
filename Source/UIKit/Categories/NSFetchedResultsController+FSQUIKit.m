//
//  NSFetchedResultsController+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 4/17/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "NSFetchedResultsController+FSQUIKit.h"


#import "FSQLogging.h"

@implementation NSFetchedResultsController (FSQUIKit)

- (void) fetch {
	NSError *error = nil;
	[self performFetch:&error];
	if (error) {
		FLog(@"Error performing fetch request: %@", [error localizedDescription]);
	}
}

- (BOOL) hasResults {
	return [self.fetchedObjects count] > 0;
}

- (NSInteger) numberOfSections {
	return (NSInteger)[self.sections count];
}

- (id) sectionAtIndex:(NSInteger)section {
	if(section < [self numberOfSections])
		return [self.sections objectAtIndex:(NSUInteger)section];
	return nil;
}

- (NSString *) nameOfSectionAtIndex:(NSInteger)section {
	return [(id<NSFetchedResultsSectionInfo>)[self sectionAtIndex:section] name];
}

- (NSString *) indexTitleOfSectionAtIndex:(NSInteger)section {
	return [(id<NSFetchedResultsSectionInfo>)[self sectionAtIndex:section] indexTitle];
}

- (NSInteger) numberOfObjectsInSection:(NSInteger)section {
	return (NSInteger)[(id<NSFetchedResultsSectionInfo>)[self sectionAtIndex:section] numberOfObjects];
}

- (NSArray *) objectsInSection:(NSInteger)section {
	return [(id<NSFetchedResultsSectionInfo>)[self sectionAtIndex:section] objects];
}

@end
