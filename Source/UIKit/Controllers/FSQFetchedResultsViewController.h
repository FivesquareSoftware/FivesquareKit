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
	NSManagedObjectContext *_managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController;
}

/** @name Subclass properties
 *  @{
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSFetchedResultsController *fetchedResultsController;

/** @} */

- (void) initialize; //< subclasses can override to share initialization
- (void) ready; //< subclasses can override to share initialization after view is loaded


@end
