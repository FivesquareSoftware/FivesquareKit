//
//  CLLocationUtils.m
//  FivesquareKit
//
//  Created by John Clayton on 1/2/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "CLLocationUtils.h"


NSString *NSStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate) {
	NSString *string = [NSString stringWithFormat:@"{ latitude: %@, longitude: %@ }", @(coordinate.latitude), @(coordinate.longitude)];
	return string;
}