//
//  FSQThumbstripBaseDataSource.h
//  FivesquareKit
//
//  Created by John Clayton on 4/20/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "FSQThumbstripView.h"

@interface FSQThumbstripBaseDataSource : NSObject <FSQThumbstripDataSource, NSFetchedResultsControllerDelegate>

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest;
- (id) objectAtIndex:(NSInteger)index;

@end
