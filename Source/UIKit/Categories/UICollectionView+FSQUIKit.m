//
//  UICollectionView+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 5/24/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "UICollectionView+FSQUIKit.h"

@implementation UICollectionView (FSQUIKit)

@dynamic orderedVisibleCells;
- (NSArray *) orderedVisibleCells {
	NSArray *sortedVisibleIndexPaths = [[self indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableArray *sortedVisibleCells = [NSMutableArray new];
	for (NSIndexPath *indexPath in sortedVisibleIndexPaths) {
		[sortedVisibleCells addObject:[self cellForItemAtIndexPath:indexPath]];
	}
	return sortedVisibleCells;
}

@end
