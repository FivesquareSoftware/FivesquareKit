//
//  MKMapView+FSQMapKit.m
//  FivesquareKit
//
//  Created by John Clayton on 7/16/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "MKMapView+FSQMapKit.h"

@implementation MKMapView (FSQMapKit)

- (void) setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSInteger)zoomLevel animated:(BOOL)animated {
	MKCoordinateSpan zoomedSpan = [self coordinateSpanForCenterCoordinate:centerCoordinate zoomLevel:zoomLevel];
	MKCoordinateRegion zoomedRegion = MKCoordinateRegionMake(centerCoordinate, zoomedSpan);
	[self setRegion:zoomedRegion animated:animated];
}

- (MKCoordinateSpan) coordinateSpanForCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSInteger)zoomLevel {
	CGPoint centerPoint = [self convertCoordinate:centerCoordinate toPointToView:self];
	CGRect centeredRect = self.frame;
	centeredRect.origin = centerPoint;
	
	NSInteger zoomPower = 20 - zoomLevel;
    CGFloat zoomScale = powf(2.f, zoomPower);
	
	CGRect zoomedRect = CGRectApplyAffineTransform(centeredRect, CGAffineTransformMakeScale(zoomScale, zoomScale));
	
	CGPoint topLeftPoint = CGPointMake(CGRectGetMinX(zoomedRect), CGRectGetMinY(zoomedRect));
	CGPoint bottomRightPoint = CGPointMake(CGRectGetMaxX(zoomedRect), CGRectGetMaxY(zoomedRect));
	
	CLLocationCoordinate2D topLeftCoordinate = [self convertPoint:topLeftPoint toCoordinateFromView:self];
	CLLocationCoordinate2D bottomRightCoordinate = [self convertPoint:bottomRightPoint toCoordinateFromView:self];
	
	MKCoordinateSpan zoomedSpan;
    zoomedSpan.latitudeDelta = topLeftCoordinate.latitude - bottomRightCoordinate.latitude;
    zoomedSpan.longitudeDelta = topLeftCoordinate.longitude - bottomRightCoordinate.longitude;
	
	return zoomedSpan;
}

//- (MKCoordinateRegion)regionFromCoordinates:(NSArray *)coordinates {
//	id<FSQLocationEntity> lastCoordinate = [coordinates lastObject];
//	CLLocationCoordinate2D upper = lastCoordinate.coordinate;
//    CLLocationCoordinate2D lower = lastCoordinate.coordinate;
//	
//	for (id<FSQLocationEntity> coordinateLike in coordinates) {
//		CLLocationCoordinate2D coordinate = coordinateLike.coordinate;
//        if(coordinate.latitude > upper.latitude) upper.latitude = coordinate.latitude;
//        if(coordinate.latitude < lower.latitude) lower.latitude = coordinate.latitude;
//        if(coordinate.longitude > upper.longitude) upper.longitude = coordinate.longitude;
//        if(coordinate.longitude < lower.longitude) lower.longitude = coordinate.longitude;
//	}
//	
//    // FIND REGION
//    MKCoordinateSpan locationSpan;
//    locationSpan.latitudeDelta = upper.latitude - lower.latitude;
//    locationSpan.longitudeDelta = upper.longitude - lower.longitude;
//    CLLocationCoordinate2D locationCenter;
//    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
//    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
//	
//    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
//    return region;
//}



@end
