//
//  MKGeometryUtils.h
//  FivesquareKit
//
//  Created by John Clayton on 7/21/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


#define MKCoordinateRegionZero MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(0, 0))

/** Converts a coordinate to a new coordinate offset by meters lat and long. */
CLLocationCoordinate2D FSQCoordinateOffsetFromCoordinate(CLLocationCoordinate2D coordinate, CLLocationDistance distanceLong, CLLocationDistance distanceLat);

CLLocationCoordinate2D FSQGetMinCoordinateForRegion(MKCoordinateRegion region);
CLLocationCoordinate2D FSQGetMaxCoordinateForRegion(MKCoordinateRegion region);

BOOL isMKCoordinateRegionZero(MKCoordinateRegion region);
BOOL MKCoordinareRegionEquals(MKCoordinateRegion region,MKCoordinateRegion otherRegion);
NSString *NSStringFromMKCoordinateRegion(MKCoordinateRegion region);
