//
//  CLGALocation+FSQCoreLocation.h
//  FivesquareKit
//
//  Created by John Clayton on 12/6/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import <CoreLocation/CLLocation.h>

@interface CLLocation (FSQCoreLocation)

- (NSString *) coordinateDescription;
- (NSString *) toQueryFormat;


@end
