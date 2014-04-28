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

CLLocationDistance FSQDiagonalSpanForRegion(MKCoordinateRegion region) {
	CLLocationCoordinate2D minCoordinate = FSQGetMinCoordinateForRegion(region);
	CLLocationCoordinate2D maxCoordinate = FSQGetMaxCoordinateForRegion(region);
	
	CLLocation *minLocation = [[CLLocation alloc] initWithLatitude:minCoordinate.latitude longitude:minCoordinate.longitude];
	CLLocation *maxLocation = [[CLLocation alloc] initWithLatitude:maxCoordinate.latitude longitude:maxCoordinate.longitude];
	CLLocationDistance distance = [maxLocation distanceFromLocation:minLocation];
	
	return distance;
}

CLLocationDistance FSQLatitudeSpanForRegion(MKCoordinateRegion region) {
	CLLocationCoordinate2D minCoordinate = FSQGetMinCoordinateForRegion(region);
	CLLocationCoordinate2D maxCoordinate = FSQGetMaxCoordinateForRegion(region);
	
	CLLocation *minLocation = [[CLLocation alloc] initWithLatitude:minCoordinate.latitude longitude:minCoordinate.longitude];
	CLLocation *maxLocation = [[CLLocation alloc] initWithLatitude:maxCoordinate.latitude longitude:minCoordinate.longitude];
	CLLocationDistance distance = [maxLocation distanceFromLocation:minLocation];
	
	return distance;
}

BOOL isMKCoordinateRegionZero(MKCoordinateRegion region) {
	return region.center.latitude == 0. && region.center.longitude == 0. && region.span.latitudeDelta == 0. && region.span.longitudeDelta == 0.;
}

BOOL MKCoordinateRegionEquals(MKCoordinateRegion region,MKCoordinateRegion otherRegion) {
	return	region.center.latitude			== otherRegion.center.latitude
	&& region.center.longitude		== otherRegion.center.longitude
	&& region.span.latitudeDelta	== otherRegion.span.latitudeDelta
	&& region.span.longitudeDelta	== otherRegion.span.longitudeDelta;
}

BOOL MKCoordinateRegionContainsCoordinate(MKCoordinateRegion region,CLLocationCoordinate2D coordinate) {
	CLLocationCoordinate2D center = region.center;
	MKCoordinateSpan span = region.span;
	
	double latitudeRadius = span.latitudeDelta/2.;
	double longitudeRadius = span.longitudeDelta/2.;
	
	double minLatitude = center.latitude-latitudeRadius;
	double maxLatitude = center.latitude+latitudeRadius;
	double minLongitude = center.longitude-longitudeRadius;
	double maxLongitude = center.longitude+longitudeRadius;
	
	return coordinate.latitude >= minLatitude && coordinate.latitude <= maxLatitude && coordinate.longitude >= minLongitude && coordinate.longitude <= maxLongitude;
}

NSString *NSStringFromMKCoordinateRegion(MKCoordinateRegion region) {
	return [NSString stringWithFormat:@"{{%f,%f},{%f,%f}}",region.center.latitude,region.center.longitude, region.span.latitudeDelta,region.span.longitudeDelta];
}


