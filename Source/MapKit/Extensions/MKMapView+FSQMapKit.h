//
//  MKMapView+FSQMapKit.h
//  FivesquareKit
//
//  Created by John Clayton on 7/16/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>


#import "FSQMacros.h"

NS_ENUM(NSUInteger, FSQMapZoomLevel) {
	FSQMapZoomLevelMin = 0
	, FSQMapZoomLevelMax = 20
};


@interface MKMapView (FSQMapKit)


/** Sets the center of the map, and the zoom level from 0 (all the way zoomed out) to 20 (all the way zoomed in). */
- (void) setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated;
- (MKCoordinateSpan) coordinateSpanForCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSInteger)zoomLevel;


@end
