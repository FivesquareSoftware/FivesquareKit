//
//  NSFetchedResultsController+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 4/17/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface NSFetchedResultsController (FSQUIKit)

- (void) fetch;

- (BOOL) hasResults;
- (NSUInteger) countOfObjects;

- (NSInteger) numberOfSections;

- (id) sectionAtIndex:(NSInteger)section;
- (NSString *) nameOfSectionAtIndex:(NSInteger)section;
- (NSString *) indexTitleOfSectionAtIndex:(NSInteger)section;

- (NSInteger) numberOfObjectsInSection:(NSInteger)section;
- (NSArray *) objectsInSection:(NSInteger)section;

- (NSArray *) objectsForIndexPaths:(NSArray *)indexPaths;

@end
