//
//  CLGALocation+FSQCoreLocation.m
//  FivesquareKit
//
//  Created by John Clayton on 12/6/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import "CLLocation+FSQCoreLocation.h"


@implementation CLLocation (FSQCoreLocation)

- (NSString *) coordinateDescription {
    return [NSString stringWithFormat:@"%f,%f",self.coordinate.latitude, self.coordinate.longitude];
}

- (NSString *) toQueryFormat {
    return [NSString stringWithFormat:@"%f,%f",self.coordinate.latitude, self.coordinate.longitude];
}

@end
