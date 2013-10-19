//
//  MKGeometry+FSQCoreLocation.m
//  FivesquareKit
//
//  Created by John Clayton on 7/21/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "MKGeometryUtils.h"

CLLocationCoordinate2D FSQCoordinateOffsetFromCoordinate(CLLocationCoordinate2D coordinate, CLLocationDistance offsetLatMeters, CLLocationDistance offsetLongMeters) {	
	MKMapPoint offsetPoint = MKMapPointForCoordinate(coordinate);
	
	CLLocationDistance metersPerPoint = MKMetersPerMapPointAtLatitude(coordinate.latitude);
	double latPoints = offsetLatMeters / metersPerPoint;
	offsetPoint.y += latPoints;
	double longPoints = offsetLongMeters / metersPerPoint;
	offsetPoint.x += longPoints;
	
	CLLocationCoordinate2D offsetCoordinate = MKCoordinateForMapPoint(offsetPoint);
	return offsetCoordinate;
}


// Conversion between unprojected and projected coordinates
//MK_EXTERN MKMapPoint MKMapPointForCoordinate(CLLocationCoordinate2D coordinate) NS_AVAILABLE(NA, 4_0);
//MK_EXTERN CLLocationCoordinate2D MKCoordinateForMapPoint(MKMapPoint mapPoint) NS_AVAILABLE(NA, 4_0);
//
//// Conversion between distances and projected coordinates
//MK_EXTERN CLLocationDistance MKMetersPerMapPointAtLatitude(CLLocationDegrees latitude) NS_AVAILABLE(NA, 4_0);
//MK_EXTERN double MKMapPointsPerMeterAtLatitude(CLLocationDegrees latitude) NS_AVAILABLE(NA, 4_0);
//
//MK_EXTERN CLLocationDistance MKMetersBetweenMapPoints(MKMapPoint a, MKMapPoint b) NS_AVAILABLE(NA, 4_0);


CLLocationCoordinate2D FSQGetMinCoordinateForRegion(MKCoordinateRegion region) {
	CLLocationCoordinate2D center = region.center;
	
	MKCoordinateSpan span = region.span;
	CLLocationDegrees latitudeSpan = span.latitudeDelta;
	CLLocationDegrees longitudeSpan = span.longitudeDelta;
	
	CLLocationCoordinate2D minCoordinate = CLLocationCoordinate2DMake(center.latitude - latitudeSpan, center.longitude - longitudeSpan);

	return minCoordinate;
}

CLLocationCoordinate2D FSQGetMaxCoordinateForRegion(MKCoordinateRegion region) {
	CLLocationCoordinate2D center = region.center;
	
	MKCoordinateSpan span = region.span;
	CLLocationDegrees latitudeSpan = span.latitudeDelta;
	CLLocationDegrees longitudeSpan = span.longitudeDelta;
	
	CLLocationCoordinate2D maxCoordinate = CLLocationCoordinate2DMake(center.latitude + latitudeSpan, center.longitude + longitudeSpan);
	
	return maxCoordinate;
}
