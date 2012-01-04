//
//  FSQFetchedResultsViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 2/14/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface FSQFetchedResultsViewController : UIViewController <NSFetchedResultsControllerDelegate> {
@protected
	NSManagedObjectContext *managedObjectContext_;
	NSFetchedResultsController *fetchedResultsController_;	
}

/** @name Subclass properties
 *  @{
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

/** @} */

@end
