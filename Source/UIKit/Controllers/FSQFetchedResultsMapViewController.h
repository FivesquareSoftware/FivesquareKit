//
//  FSQFetchedResultsMapViewController.h
//  FivesquareKit
//
//  Created by John Clayton on 2/26/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQFetchedResultsViewController.h"

#import <MapKit/MapKit.h>

@interface FSQFetchedResultsMapViewController : FSQFetchedResultsViewController

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

/** The distance in meters for the map's region span. Changing this will change the zoom level of the map and also the fetched results controller's predicate so that . Defaults to 1000 meters. */
@property (nonatomic) NSUInteger zoomSpan;

- (void) setZoomSpan:(NSUInteger)zoomSpan animated:(BOOL)animated;

/** Subclasses should override this to provide a fetched results controller that returns fetched objects that fit into the region. */
//- (void) fetchedResultsControllerForRegion:(MKCoordinateRegion *)region;

- (void) initialize; //< subclasses can override to share initialization


@end


/** The entity for this controller's fetch request must conform to this protocol. */
@protocol FSQLocationEntity <NSObject>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@end
