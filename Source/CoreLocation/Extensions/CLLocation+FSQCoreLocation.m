//
//  CLGALocation+FSQCoreLocation.m
//  FivesquareKit
//
//  Created by John Clayton on 12/6/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import "CLLocation+FSQCoreLocation.h"

#import <ImageIO/ImageIO.h>

#import "NSString+FSQFoundation.h"

@implementation CLLocation (FSQCoreLocation)

+ (id) withGPSDictionary:(NSDictionary *)GPSDictionary {
	
	NSString *latitudeString = GPSDictionary[(id)kCGImagePropertyGPSLatitude];
	NSString *longitudeString = GPSDictionary[(id)kCGImagePropertyGPSLongitude];
	NSString *latitudeRef = GPSDictionary[(id)kCGImagePropertyGPSLatitudeRef];
	NSString *longitudeRef = GPSDictionary[(id)kCGImagePropertyGPSLongitudeRef];
	
	double absLatitude = [latitudeString doubleValue];
	double latitude = [latitudeRef isEqualToString:@"N"] ? absLatitude : -absLatitude;
	
	double absLongitude = [longitudeString doubleValue];
	double longitude = [longitudeRef isEqualToString:@"E"] ? absLongitude : -absLongitude;

	
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
	
	double altitude = [GPSDictionary[(id)kCGImagePropertyGPSAltitude] doubleValue];
	double direction = [GPSDictionary[(id)kCGImagePropertyGPSTrack] doubleValue];
	double speed = [GPSDictionary[(id)kCGImagePropertyGPSSpeed] doubleValue];
	NSString *speedRef = GPSDictionary[(id)kCGImagePropertyGPSSpeedRef];
	if ([speedRef isEqualToString:@"K"]) {
		speed = speed/1000.;
	}
	//TODO: handle non-metric speeds units?
	
	NSString *datestamp = GPSDictionary[(id)kCGImagePropertyGPSDateStamp];
	NSString *timestamp = GPSDictionary[(id)kCGImagePropertyGPSTimeStamp];
	
	NSString *datetimeStamp = nil;
	NSDateFormatter *timestampDateFormatter = [[NSDateFormatter alloc] init];
	[timestampDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDate *timestampDate = nil;
	if ([NSString isNotEmpty:datestamp] && [NSString isNotEmpty:timestamp]) {
		datetimeStamp = [NSString stringWithFormat:@"%@ %@",datestamp,timestamp];
		[timestampDateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss.SSSSSS"];
	}
	else if ([NSString isNotEmpty:datestamp]) {
		datetimeStamp = datestamp;
		[timestampDateFormatter setDateFormat:@"yyyy:MM:dd"];
	}
	
	if (datetimeStamp) {
		timestampDate = [timestampDateFormatter dateFromString:datetimeStamp];
	}
	
	CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:0 verticalAccuracy:0 course:direction speed:speed timestamp:timestampDate];
	return location;
}

@dynamic coordinateDescription;
- (NSString *) coordinateDescription {
    return [NSString stringWithFormat:@"%f,%f",self.coordinate.latitude, self.coordinate.longitude];
}

@dynamic GPSDictionary;
- (NSDictionary *) GPSDictionary {
	
	NSMutableDictionary *GPSDictionary = [NSMutableDictionary new];
	
	GPSDictionary[(id)kCGImagePropertyGPSVersion] = @"2.2.0.0";
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	
	[dateFormatter setDateFormat:@"yyyy:MM:dd"];
	NSString *datestamp = [dateFormatter stringFromDate:self.timestamp];
	
	[dateFormatter setDateFormat:@"HH:mm:ss.SSSSSS"];
	NSString *timestamp = [dateFormatter stringFromDate:self.timestamp];
	
	double latitude = self.coordinate.latitude;
	double longitude = self.coordinate.longitude;
	
	NSString *latitudeRef;
	if (latitude < 0) {
		latitude = -latitude;
		latitudeRef = @"S";
	}
	else {
		latitudeRef = @"N";
	}

	NSString *longitudeRef;
	if (longitude < 0) {
		longitude = -longitude;
		longitudeRef = @"E";
	}
	else {
		longitudeRef = @"W";
	}

	double speed = self.speed*1000.;
	
	
	GPSDictionary[(id)kCGImagePropertyGPSAltitude] = @(self.altitude);
	GPSDictionary[(id)kCGImagePropertyGPSDateStamp] = datestamp;
	GPSDictionary[(id)kCGImagePropertyGPSLatitude] = @(latitude);
	GPSDictionary[(id)kCGImagePropertyGPSLatitudeRef] = latitudeRef;
	GPSDictionary[(id)kCGImagePropertyGPSLongitude] = @(longitude);
	GPSDictionary[(id)kCGImagePropertyGPSLongitudeRef] = longitudeRef;
	GPSDictionary[(id)kCGImagePropertyGPSSpeed] = @(speed);
	GPSDictionary[(id)kCGImagePropertyGPSSpeedRef] = @"K";
	GPSDictionary[(id)kCGImagePropertyGPSTimeStamp] = timestamp;
	GPSDictionary[(id)kCGImagePropertyGPSTrack] = @(self.course);
	GPSDictionary[(id)kCGImagePropertyGPSTrackRef] = @"T";
	
	return GPSDictionary;
}

- (NSString *) toQueryFormat {
    return [NSString stringWithFormat:@"%f,%f",self.coordinate.latitude, self.coordinate.longitude];
}

@end
