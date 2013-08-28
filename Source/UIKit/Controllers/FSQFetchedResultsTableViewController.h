//
//  FSQFetchedResultsTableViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 2/21/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "FSQFetchedResultsViewController.h"

@interface FSQFetchedResultsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
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



@property (nonatomic) BOOL editable;
@property (nonatomic) BOOL reordering;
@property (nonatomic) NSUInteger mutatingSectionIndex;
@property (nonatomic) NSUInteger fetchedResultsTableRowOffset;
@property (nonatomic) NSUInteger fetchedResultsTableSection;
@property (nonatomic) BOOL showsPlaceholderRow;
@property (nonatomic) BOOL animateTableUpdates;

@property (nonatomic, assign) UITableViewRowAnimation insertRowAnimationType;
@property (nonatomic, assign) UITableViewRowAnimation deleteRowAnimationType;
@property (nonatomic, assign) UITableViewRowAnimation moveRowAnimationType;


- (void) initialize; //< subclasses can override to share initialization

- (NSIndexPath *) fetchedResultsIndexPathForTableIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *) tableIndexPathForFetchedResultsIndexPath:(NSIndexPath *)indexPath;	

/** Override this in your subclass to configure a cell with a fetched object. */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
