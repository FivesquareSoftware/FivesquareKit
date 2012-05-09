//
//  FSQFetchedResultsTableViewController.m
//  FivesquareKit
//
//  Created by John Clayton on 2/21/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsTableViewController.h"


#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"
#import "NSFetchedResultsController+FSQUIKit.h"
#import "UITableView+FSQUIKit.h"


@interface FSQFetchedResultsTableViewController ()
- (void) initialize;
@end


@implementation FSQFetchedResultsTableViewController


// ========================================================================== //

#pragma mark - Properties

@synthesize tableView=tableView_;


@synthesize editable=editable_;
@synthesize reordering=reordering_;
@synthesize mutatingSectionIndex=mutatingSectionIndex_;
@synthesize fetchedResultsTableRowOffset=fetchedResultsTableRowOffset_;
@synthesize fetchedResultsTableSection=fetchedResultsTableSection_;
@synthesize showsPlaceholderRow=showsPlaceholderRow_;
@synthesize animateTableUpdates=animateTableUpdates_;
@synthesize tableRowAnimationType=tableRowAnimationType_;
@synthesize clearsSelectionOnViewWillAppear=clearsSelectionOnViewWillAppear_;



// ========================================================================== //

#pragma mark - Object

- (void) initialize {
	animateTableUpdates_ = YES;
	tableRowAnimationType_ = UITableViewRowAnimationNone;
	clearsSelectionOnViewWillAppear_ = YES;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil) {
		[self initialize];
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
		[self initialize];
    }
    return self;
}

- (void) dealloc {
	fetchedResultsController_.delegate = nil;
	
}


// ========================================================================== //

#pragma mark - View Controller


- (void) viewDidLoad {
	[super viewDidLoad];
	if (self.tableView == nil) {
		FSQAssert([self.view isKindOfClass:[UITableView class]],@"View is not a table view");
		self.tableView = (UITableView *)self.view;
	}
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.clearsSelectionOnViewWillAppear) {
		[self.tableView clearSelectionAnimated:animated];
	}
	[self.tableView reloadData];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    if( ! editing) {
		self.reordering = NO; // just in case something went wrong
		
		NSError *error = nil;
		if( ! [[self managedObjectContext] save:&error]) {
			FSQAssert(NO,@"Error saving edited context %@ (%@)",[error localizedDescription],[error userInfo]);
		}
		
    }
    [super setEditing:editing animated:animated];
}


// ========================================================================== //

#pragma mark - Table View Methods


- (NSIndexPath *) fetchedResultsIndexPathForTableIndexPath:(NSIndexPath *)indexPath {
	if(indexPath == nil) return nil;
	return [NSIndexPath indexPathForRow:indexPath.row - (NSInteger)fetchedResultsTableRowOffset_ inSection:indexPath.section - (NSInteger)fetchedResultsTableSection_];
}

- (NSIndexPath *) tableIndexPathForFetchedResultsIndexPath:(NSIndexPath *)indexPath {
	if(indexPath == nil) return nil;
	return [NSIndexPath indexPathForRow:indexPath.row + (NSInteger)fetchedResultsTableRowOffset_ inSection:indexPath.section + (NSInteger)fetchedResultsTableSection_];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count =  [self.fetchedResultsController numberOfObjectsInSection:section - (NSInteger)fetchedResultsTableSection_];
	if(count < 1 && self.showsPlaceholderRow)
		count = 1;
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self responsibility:_cmd];
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	[FSQAsserter subclass:self warn:_cmd];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == fetchedResultsTableSection_)
		return editable_;
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section != fetchedResultsTableSection_) return;
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:[self fetchedResultsIndexPathForTableIndexPath:indexPath]];
		[[object managedObjectContext] deleteObject:object];
		
		NSError *error = nil;
		if( ! [[object managedObjectContext] save:&error]) {
			FSQAssert(NO,@"Error deleting object %@ (%@)",[error localizedDescription],[error userInfo]);
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.fetchedResultsController nameOfSectionAtIndex:section - (NSInteger)fetchedResultsTableSection_];
}

- (CGFloat)tableView:(UITableView *)inTableView heightForHeaderInSection:(NSInteger)section {
	NSString *title = [self tableView:inTableView titleForHeaderInSection:section];
	if(title) {
		return inTableView.sectionHeaderHeight;
	}
	return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}






// ========================================================================== //

#pragma mark -  NSFetchedResultsController Delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if(self.reordering) return;
	if( ! self.animateTableUpdates ) return;
	
	self.mutatingSectionIndex = NSNotFound;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	if(self.reordering) return;
	if( ! self.animateTableUpdates ) return;

	
	if(type == NSFetchedResultsChangeInsert) self.mutatingSectionIndex = sectionIndex;
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex + fetchedResultsTableSection_]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex + fetchedResultsTableSection_]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	if(self.reordering) return;	
	if( ! self.animateTableUpdates ) return;
	
	BOOL changedSection = [[[anObject changedValues] allKeys] containsObject:[self.fetchedResultsController sectionNameKeyPath]];
    if ( (NSFetchedResultsChangeUpdate == type) && changedSection) {
        type = NSFetchedResultsChangeMove;
        newIndexPath = indexPath;
    }
	
	
	NSIndexPath *tableIndexPath = [self tableIndexPathForFetchedResultsIndexPath:indexPath];
	NSIndexPath *newTableIndexPath = [self tableIndexPathForFetchedResultsIndexPath:newIndexPath];
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
			if(newIndexPath.section == self.mutatingSectionIndex) break;
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newTableIndexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:tableIndexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:tableIndexPath]
					atIndexPath:tableIndexPath];
            break;
			
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:tableIndexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newTableIndexPath]
								  withRowAnimation:UITableViewRowAnimationTop];
			break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {	
	if(self.reordering) {
		self.reordering = NO;
		return;
	}

	self.mutatingSectionIndex = NSNotFound;

	if( ! self.animateTableUpdates ) {
		[self.tableView reloadData];
	} else {
		[self.tableView endUpdates];
	}
	
}


@end
