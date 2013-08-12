//
//  CLGALocation+FSQCoreLocation.h
//  FivesquareKit
//
//  Created by John Clayton on 12/6/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import <CoreLocation/CLLocation.h>
#import <ImageIO/ImageIO.h>

@interface CLLocation (FSQCoreLocation)

+ (id) withGPSDictionary:(NSDictionary *)GPSDictionary;

@property (nonatomic, readonly) NSString *coordinateDescription;
@property (nonatomic, readonly) NSDictionary *GPSDictionary;

- (NSString *) toQueryFormat;


@end
