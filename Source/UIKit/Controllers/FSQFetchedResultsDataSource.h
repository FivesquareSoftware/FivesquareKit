//
//  FSQFetchedResultsDataSource.h
//  FivesquareKit
//
//  Created by John Clayton on 7/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface FSQFetchedResultsDataSource : NSObject <NSFetchedResultsControllerDelegate> {
	@protected
	NSManagedObjectContext *_managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController;
}

/** @name Subclass properties
 *  @{
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSFetchedResultsController *fetchedResultsController;

/** @} */


@property (nonatomic, weak) id<NSObject,NSFetchedResultsControllerDelegate> delegate;

@end
