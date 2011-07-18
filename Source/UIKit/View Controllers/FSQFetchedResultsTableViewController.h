//
//  FSQFetchedResultsTableViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 2/21/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FSQFetchedResultsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
	UITableView *tableViewOutlet;

	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	
	BOOL editable;
	
	BOOL reordering;
	NSUInteger mutatingSectionIndex;
	
	NSUInteger fetchedResultsTableRowOffset;
	NSUInteger fetchedResultsTableSection;
	
	BOOL showsPlaceholderRow;
	
	BOOL animateTableUpdates;
	
	UITableViewRowAnimation tableRowAnimationType;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, assign) BOOL editable;

@property (nonatomic, assign) BOOL reordering;
@property (nonatomic, assign) NSUInteger mutatingSectionIndex;

@property (nonatomic, assign) NSUInteger fetchedResultsTableRowOffset;
@property (nonatomic, assign) NSUInteger fetchedResultsTableSection;

@property (nonatomic, assign) BOOL showsPlaceholderRow;

@property (nonatomic, assign) BOOL animateTableUpdates;
/** Right now does nothing. */
@property (nonatomic, assign) UITableViewRowAnimation tableRowAnimationType;



- (NSIndexPath *) fetchedResultsIndexPathForTableIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *) tableIndexPathForFetchedResultsIndexPath:(NSIndexPath *)indexPath;	

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
