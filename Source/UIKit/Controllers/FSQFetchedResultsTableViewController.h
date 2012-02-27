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

@interface FSQFetchedResultsTableViewController : FSQFetchedResultsViewController <UITableViewDataSource, UITableViewDelegate> 

@property (nonatomic, strong) IBOutlet UITableView *tableView;


@property (nonatomic) BOOL editable;
@property (nonatomic) BOOL reordering;
@property (nonatomic) NSUInteger mutatingSectionIndex;
@property (nonatomic) NSUInteger fetchedResultsTableRowOffset;
@property (nonatomic) NSUInteger fetchedResultsTableSection;
@property (nonatomic) BOOL showsPlaceholderRow;
@property (nonatomic) BOOL animateTableUpdates;
/** Right now does nothing. */
@property (nonatomic, assign) UITableViewRowAnimation tableRowAnimationType;

/** @see UITablewViewController.clearsSelectionOnViewWillAppear */
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

- (NSIndexPath *) fetchedResultsIndexPathForTableIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *) tableIndexPathForFetchedResultsIndexPath:(NSIndexPath *)indexPath;	

/** Override this in your subclass to configure a cell with a fetched object. */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
