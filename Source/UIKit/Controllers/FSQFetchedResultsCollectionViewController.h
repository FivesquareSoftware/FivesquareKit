//
//  FSQFetchedResultsCollectionViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 7/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#ifdef __IPHONE_6_0

@interface FSQFetchedResultsCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
@protected
	NSManagedObjectContext *_managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController;
}

/** @name Properties for subclasses to override
 *  @{
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

/** @} */


/** Override this in your subclass to configure a cell with a fetched object. */
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end


#endif