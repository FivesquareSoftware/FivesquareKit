//
//  FSQThumbstripBaseDataSource_Protected.h
//  FivesquareKit
//
//  Created by John Clayton on 4/20/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQThumbstripBaseDataSource.h"

@interface FSQThumbstripBaseDataSource ()
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext; ///< Subclasses must provide an implementation
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController; ///< Subclasses must provide an implementation
@end
