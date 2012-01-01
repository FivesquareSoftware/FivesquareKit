//
//  FSQLocationManager.m
//  FivesquareKit
//
//  Created by John Clayton on 6/23/2008.
//  Copyright Fivesquare Software, LLC 2008. All rights reserved.
//

#import "FSQLocationManager.h"



NSString *kFSQLocationManagerChangedNotification = @"kFSQLocationManagerChangedNotification";
NSString *kFSQLocationManagerSearchAbortedNotification = @"kFSQLocationManagerSearchAbortedNotification";
NSString *kFSQLocationManagerKeyLocation = @"kFSQLocationManagerKeyLocation";
NSString *kFSQLocationManagerKeyErrorCode = @"kFSQLocationManagerKeyErrorCode";
NSString *kFSQLocationManagerKeyErrorMessage = @"kFSQLocationManagerKeyErrorMessage";



@interface FSQLocationManager()
- (void) locationSearchTimeLimitReached:(NSTimer *)timer;
- (void) postAbortNotificationWithErrorMessage:(NSString *)errorMessage errorCode:(NSInteger)errorCode;
@end

@implementation FSQLocationManager

@synthesize locationManager;
@synthesize currentLocation;
@synthesize locationUpdatesGiveUpAfter;
@synthesize locationChangeNotificationMeters;
@synthesize locationUpdatesStartedOn;
@synthesize locationServicesAbortTimer;


// ========================================================================== //

#pragma mark -
#pragma mark Properties



- (CLLocationManager *) locationManager {
    if(locationManager == nil) {
        CLLocationManager *lman = [[CLLocationManager alloc] init];
        lman.delegate = self;
        self.locationManager = lman;
    }
    return locationManager;
}




// ========================================================================== //

#pragma mark -
#pragma mark Object



- (void)dealloc {

	if([self.locationServicesAbortTimer isValid]) {
		[self.locationServicesAbortTimer invalidate];
	}
	
}




// ========================================================================== //

#pragma mark -
#pragma mark Public



- (void) startFetchingCurrentLocationAccurateTo:(CLLocationAccuracy)accuracy 
                    notifyingForChangesOfMeters:(NSUInteger)meters
                           givingUpAfterSeconds:(NSTimeInterval)seconds {
    self.locationChangeNotificationMeters = meters;
    self.locationUpdatesGiveUpAfter = seconds;
    self.locationUpdatesStartedOn = [NSDate date];
    self.locationManager.desiredAccuracy = accuracy;
//	self.locationManager.distanceFilter = meters;
    [self.locationManager startUpdatingLocation];
    self.locationServicesAbortTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(locationSearchTimeLimitReached:) userInfo:nil repeats:NO];
}


// ========================================================================== //

#pragma mark -
#pragma mark Location Manager Delegate

- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation {
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval fromWhenUpdatesStarted = [eventDate timeIntervalSinceDate:self.locationUpdatesStartedOn];
    if (fromWhenUpdatesStarted > 0) { // we have an update since we started looking
        if (signbit(newLocation.horizontalAccuracy) == 0) { // we have a valid location
            CLLocationDistance distanceMoved = 0; // if resolution is greater than 0 we will end up tossing away an initial event
            if(oldLocation) {
                distanceMoved = [newLocation distanceFromLocation:oldLocation];
            }
            if(distanceMoved >= self.locationChangeNotificationMeters) { // we have a new location
                [self.locationManager stopUpdatingLocation];
                if([self.locationServicesAbortTimer isValid]) {
                    [self.locationServicesAbortTimer invalidate];
                }
                self.currentLocation = newLocation;
                [[NSNotificationCenter defaultCenter] 
				 postNotificationName:kFSQLocationManagerChangedNotification 
				 object:self
				 userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:kFSQLocationManagerKeyLocation]];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSMutableString *errorString = [[NSMutableString alloc] init];
	NSInteger errorCode = 0;
	if ([error domain] == kCLErrorDomain) {
        errorCode = [error code];
		switch (errorCode) {
                // This error code is usually returned whenever user taps "Don't Allow" in response to
                // being told your app wants to access the current location. Once this happens, you cannot
                // attempt to get the location again until the app has quit and relaunched.
                //
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
                //
			case kCLErrorDenied:
				[errorString appendFormat:@"%@", NSLocalizedString(@"LocationDenied", nil)];
				break;
                
                // This error code is usually returned whenever the device has no data or WiFi connectivity,
                // or when the location cannot be determined for some other reason.
                //
                // CoreLocation will keep trying, so you can keep waiting, or prompt the user.
                //
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@", NSLocalizedString(@"LocationUnknown", nil)];
				break;
                
                // We shouldn't ever get an unknown error code, but just in case...
                //
			default:
				[errorString appendFormat:@"%@ %d", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	} else {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
	[self postAbortNotificationWithErrorMessage:errorString
									  errorCode:errorCode];
	
}

- (void) locationSearchTimeLimitReached:(NSTimer *)timer {
	[self postAbortNotificationWithErrorMessage:@"Location search time limit reached"
									  errorCode:kFSQLocationManagerErrorCodeTimeout];
}

- (void) postAbortNotificationWithErrorMessage:(NSString *)errorMessage errorCode:(NSInteger)errorCode {
    [self.locationManager stopUpdatingLocation];
	if([self.locationServicesAbortTimer isValid]) {
		[self.locationServicesAbortTimer invalidate];
	}
    self.currentLocation = self.locationManager.location;
	
	// Why do i have to do this?
	id loc; 
	if (self.currentLocation == nil)
		loc = [NSNull null];
	else
		loc = self.currentLocation;
	
	id msg;
	if(errorMessage == nil)
		msg = [NSNull null];
	else
		msg = errorMessage;
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  loc
							  , kFSQLocationManagerKeyLocation
							  , msg
							  , kFSQLocationManagerKeyErrorMessage
							  , [NSNumber numberWithInteger:errorCode]
							  , kFSQLocationManagerKeyErrorCode
							  , nil];
    [[NSNotificationCenter defaultCenter] 
	 postNotificationName:kFSQLocationManagerSearchAbortedNotification 
	 object:self
	 userInfo:userInfo
	 ];
}


@end
