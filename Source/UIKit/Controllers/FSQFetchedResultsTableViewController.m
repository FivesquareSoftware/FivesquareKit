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

@implementation FSQFetchedResultsTableViewController


// ========================================================================== //

#pragma mark -
#pragma mark Properties

@synthesize tableView=tableViewOutlet;

@synthesize managedObjectContext;

@dynamic fetchedResultsController;


@synthesize editable;

@synthesize reordering;
@synthesize mutatingSectionIndex;

@synthesize fetchedResultsTableRowOffset;
@synthesize fetchedResultsTableSection;

@synthesize showsPlaceholderRow;

@synthesize animateTableUpdates;
@synthesize tableRowAnimationType;


- (NSFetchedResultsController *) fetchedResultsController {
	FSQAssert(NO, @"Implement fetchedResultsController in %@",[self className]);
	return nil;
}



// ========================================================================== //

#pragma mark -
#pragma mark Object


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil) {
		animateTableUpdates = YES;
		tableRowAnimationType = UITableViewRowAnimationNone;
	}
	return self;
}


- (void) dealloc {
	fetchedResultsController.delegate = nil;
	
}


// ========================================================================== //

#pragma mark -
#pragma mark View Controller

- (void) viewWillAppear:(BOOL)animated {
	[self.fetchedResultsController fetch];
	[super viewWillAppear:animated];
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

#pragma mark -
#pragma mark Table View Methods


- (NSIndexPath *) fetchedResultsIndexPathForTableIndexPath:(NSIndexPath *)indexPath {
	if(indexPath == nil) return nil;
	return [NSIndexPath indexPathForRow:indexPath.row - fetchedResultsTableRowOffset inSection:indexPath.section - fetchedResultsTableSection];
}

- (NSIndexPath *) tableIndexPathForFetchedResultsIndexPath:(NSIndexPath *)indexPath {
	if(indexPath == nil) return nil;
	return [NSIndexPath indexPathForRow:indexPath.row + fetchedResultsTableRowOffset inSection:indexPath.section + fetchedResultsTableSection];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count =  [self.fetchedResultsController numberOfObjectsInSection:section - fetchedResultsTableSection];
	if(count < 1 && self.showsPlaceholderRow)
		count = 1;
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FSQAssert(NO, @"Implement tableView:cellForRowAtIndexPath: in %@", [self className]);
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	FSQAssert(NO,@"Implement configureCell:atIndexPath: in %@", [self className]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == fetchedResultsTableSection)
		return editable;
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section != fetchedResultsTableSection) return;
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:[self fetchedResultsIndexPathForTableIndexPath:indexPath]];
		[[object managedObjectContext] deleteObject:object];
		
		NSError *error = nil;
		if( ! [[object managedObjectContext] save:&error]) {
			NSAssert2(NO,@"Error deleting object %@ (%@)",[error localizedDescription],[error userInfo]);
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.fetchedResultsController nameOfSectionAtIndex:section - fetchedResultsTableSection];
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

#pragma mark -
#pragma mark NSFetchedResultsController Delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
#ifndef __IPHONE_3_1
	FSQAssert(NO, @"This class in not compatible with the SDK versions < 3.1");
#endif
	
	if(self.reordering) return;
	if( ! self.animateTableUpdates ) return;
	
	self.mutatingSectionIndex = NSNotFound;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type {
	
	if(self.reordering) return;
	if( ! self.animateTableUpdates ) return;

	
	if(type == NSFetchedResultsChangeInsert) self.mutatingSectionIndex = sectionIndex;
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex + fetchedResultsTableSection]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex + fetchedResultsTableSection]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
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
