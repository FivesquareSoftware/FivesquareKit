//
//  FSQFetchedResultsCollectionViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 7/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


NS_CLASS_AVAILABLE_IOS(6_0) @interface FSQFetchedResultsCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate> {
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

- (void) initialize; //< subclasses can override to share initialization
- (void) configureCollectionView; //< subclasses can override to share collection view configuration, after which reloadData is called

@property (nonatomic) BOOL animatesCollectionViewUpdates;
@property (nonatomic) BOOL animatesItemReloads;

/** Override this in your subclass to configure a cell with a fetched object. */
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureSupplementaryView:(UICollectionReusableView *)supplementaryView atIndexPath:(NSIndexPath *)indexPath;


@end

