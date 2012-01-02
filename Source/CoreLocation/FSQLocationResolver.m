//
//  FSQLocationResolver.m
//  FivesquareKit
//
//  Created by John Clayton on 6/23/2008.
//  Copyright Fivesquare Software, LLC 2008. All rights reserved.
//

#import "FSQLocationResolver.h"



NSString *kFSQLocationResolverCompletedResolutionNotification = @"kFSQLocationManagerChangedNotification";
NSString *kFSQLocationResolverKeyLocation = @"Location";
NSString *kFSQLocationResolverKeyError = @"Error";
NSString *kFSQLocationResolverKeyAborted = @"Aborted";



@interface FSQLocationResolver()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *locationUpdatesStartedOn;
@property (nonatomic, strong) NSTimer *locationServicesAbortTimer;
@property (nonatomic, copy) FSQLocationResolverCompletionHandler completionHandler;

- (void) locationSearchTimeLimitReached:(NSTimer *)timer;
- (void) handleResolutionCompletion;
@end


@implementation FSQLocationResolver



// ========================================================================== //

#pragma mark - Properties


// Public

@synthesize resolving=resolving_;
@synthesize aborted=aborted_;
@synthesize currentLocation=currentLocation_;
@synthesize error=error_;


// Private

@synthesize locationManager=locationManager_;
@synthesize locationUpdatesStartedOn=locationUpdatesStartedOn_;
@synthesize locationServicesAbortTimer=locationServicesAbortTimer_;
@synthesize completionHandler=completionHandler_;


- (CLLocationManager *) locationManager {
    if(locationManager_ == nil) {
        CLLocationManager *locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        locationManager_ = locationManager;
    }
    return locationManager_;
}




// ========================================================================== //

#pragma mark - Object



- (void)dealloc {
	if([self.locationServicesAbortTimer isValid]) {
		[self.locationServicesAbortTimer invalidate];
	}
}




// ========================================================================== //

#pragma mark - Public



- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout {
	return [self resolveLocationAccurateTo:accuracy givingUpAfter:timeout completionHandler:nil];
}

- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout completionHandler:(FSQLocationResolverCompletionHandler)handler {
	
	if (NO == [CLLocationManager locationServicesEnabled]) return NO;
	if (self.isResolving) return NO;
	
	self.resolving = YES;
	self.aborted = NO;
	
	self.completionHandler = handler;
	
	self.locationUpdatesStartedOn = [NSDate date];
    self.locationManager.desiredAccuracy = accuracy;
    [self.locationManager startUpdatingLocation];
    self.locationServicesAbortTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(locationSearchTimeLimitReached:) userInfo:nil repeats:NO];
	return YES;
}



// ========================================================================== //

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval fromWhenUpdatesStarted = [eventDate timeIntervalSinceDate:self.locationUpdatesStartedOn];
	
	if (fromWhenUpdatesStarted <= 0) return; // this update was cached before we started resolving
	if (newLocation.horizontalAccuracy < 0) return; // an invalid location

	if (self.currentLocation == nil || self.currentLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        self.currentLocation = newLocation;
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
			[self.locationManager stopUpdatingLocation];
			[self handleResolutionCompletion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) { // Unknown means we could recover
		[self.locationManager stopUpdatingLocation];
		self.currentLocation = self.locationManager.location; // get the best location we can
		self.error = error;
		[self handleResolutionCompletion];
	}
}


// ========================================================================== //

#pragma mark - Timeout


- (void) locationSearchTimeLimitReached:(NSTimer *)timer {
	self.aborted = YES;
	[self.locationManager stopUpdatingLocation];
	self.currentLocation = self.locationManager.location; // get the best location we can
	[self handleResolutionCompletion];
}


// ========================================================================== //

#pragma mark - Handlers

- (void) handleResolutionCompletion {
	
	NSMutableDictionary *info = [NSMutableDictionary new];
	if (self.currentLocation) {
		[info setObject:self.currentLocation forKey:kFSQLocationResolverKeyLocation];
	}
	if (self.error) {
		[info setObject:self.error forKey:kFSQLocationResolverKeyError];
	}
	[info setObject:[NSNumber numberWithBool:self.aborted] forKey:kFSQLocationResolverKeyAborted];
	
	if (self.completionHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.completionHandler(info);
		});
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:kFSQLocationResolverCompletedResolutionNotification object:self userInfo:info];	
	}
	
	self.resolving = NO;
}




@end
