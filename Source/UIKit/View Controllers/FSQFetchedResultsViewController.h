//
//  FSQFetchedResultsViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 2/14/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface FSQFetchedResultsViewController : UIViewController {
	NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;

@end
