//
//  FSQLocationManager.h
//  FivesquareKit
//
//  Created by John Clayton on 6/23/2008.
//  Copyright Fivesquare Software, LLC 2008. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



extern NSString *kFSQLocationManagerChangedNotification;
extern NSString *kFSQLocationManagerSearchAbortedNotification;
extern NSString *kFSQLocationManagerKeyLocation;
extern NSString *kFSQLocationManagerKeyErrorCode;
extern NSString *kFSQLocationManagerKeyErrorMessage;

#define kFSQLocationManagerErrorCodeTimeout 99
#define kFSQLocationManagerErrorCodeNoNetwork 55



@interface FSQLocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSTimeInterval locationUpdatesGiveUpAfter;
    NSUInteger locationChangeNotificationMeters;
    NSDate *locationUpdatesStartedOn;
    NSTimer *locationServicesAbortTimer;
	
}


@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, assign) NSTimeInterval locationUpdatesGiveUpAfter;
@property (nonatomic, assign) NSUInteger locationChangeNotificationMeters;
@property (nonatomic,retain) NSDate *locationUpdatesStartedOn;
@property (nonatomic, retain) NSTimer *locationServicesAbortTimer;


- (void) startFetchingCurrentLocationAccurateTo:(CLLocationAccuracy)accuracy 
                    notifyingForChangesOfMeters:(NSUInteger)meters
                           givingUpAfterSeconds:(NSTimeInterval)seconds;


@end
