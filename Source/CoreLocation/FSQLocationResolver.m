//
//  FSQLocationResolver.m
//  FivesquareKit
//
//  Created by John Clayton on 6/23/2008.
//  Copyright Fivesquare Software, LLC 2008. All rights reserved.
//

#import "FSQLocationResolver.h"

#import "FSQLogging.h"

NSString *kFSQLocationResolverCompletedResolutionNotification = @"kFSQLocationManagerChangedNotification";
NSString *kFSQLocationResolverKeyLocation = @"Location";
NSString *kFSQLocationResolverKeyError = @"Error";
NSString *kFSQLocationResolverKeyAborted = @"Aborted";



@interface FSQLocationResolver()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *locationUpdatesStartedOn;
@property (nonatomic, strong) NSTimer *locationServicesAbortTimer;
//@property (nonatomic, copy) FSQLocationResolverCompletionHandler completionHandler;
@property (nonatomic, strong) NSMutableSet *completionHandlers;

- (void) locationSearchTimeLimitReached:(NSTimer *)timer;
- (void) handleResolutionCompletion;
@end


@implementation FSQLocationResolver



// ========================================================================== //

#pragma mark - Properties


// Public



// Private



- (CLLocationManager *) locationManager {
    if(_locationManager == nil) {
        CLLocationManager *locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        _locationManager = locationManager;
    }
    return _locationManager;
}




// ========================================================================== //

#pragma mark - Object



- (void)dealloc {
	[_completionHandlers removeAllObjects];
	if([self.locationServicesAbortTimer isValid]) {
		[self.locationServicesAbortTimer invalidate];
	}
}

- (id)init {
    self = [super init];
    if (self) {
        _completionHandlers = [NSMutableSet new];
    }
    return self;
}



// ========================================================================== //

#pragma mark - Public



- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout {
	return [self resolveLocationAccurateTo:accuracy givingUpAfter:timeout completionHandler:nil];
}

- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout completionHandler:(FSQLocationResolverCompletionHandler)handler {
	
	if (NO == [CLLocationManager locationServicesEnabled]) return NO;
	
	[_completionHandlers addObject:[handler copy]];
	if (self.isResolving) return YES;
	
	self.resolving = YES;
	self.aborted = NO;
	
//	self.completionHandler = handler;
	
	self.locationUpdatesStartedOn = [NSDate date];
    self.locationManager.desiredAccuracy = accuracy;
    [self.locationManager startUpdatingLocation];
	
	if (self.locationServicesAbortTimer) {
		[self.locationServicesAbortTimer invalidate];
		self.locationServicesAbortTimer = nil;
	}
    self.locationServicesAbortTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(locationSearchTimeLimitReached:) userInfo:nil repeats:NO];

	// experimenting with getting a cached location
	//	self.currentLocation = self.locationManager.location;
	
	return YES;
}



// ========================================================================== //

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    FLog(@"didUpdateToLocation:%@ fromLocation:%@",newLocation,oldLocation);
	NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval fromWhenUpdatesStarted = [eventDate timeIntervalSinceDate:self.locationUpdatesStartedOn];
	FLogSimple();
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
	
	NSError *abortError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorLocationUnknown userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Timed out resolving location. Cached location may have been good already.", @"FSQLocationResolver timeout error description") }];
	self.error = abortError;
	
	[self handleResolutionCompletion];
}


// ========================================================================== //

#pragma mark - Handlers

- (void) handleResolutionCompletion {
	if (self.locationServicesAbortTimer) {
		[self.locationServicesAbortTimer invalidate];
		self.locationServicesAbortTimer = nil;
	}
	
	NSMutableDictionary *info = [NSMutableDictionary new];
	if (self.currentLocation) {
		[info setObject:self.currentLocation forKey:kFSQLocationResolverKeyLocation];
	}
	if (self.error) {
		[info setObject:self.error forKey:kFSQLocationResolverKeyError];
	}
	[info setObject:@(self.aborted) forKey:kFSQLocationResolverKeyAborted];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kFSQLocationResolverCompletedResolutionNotification object:self userInfo:info];
	[_completionHandlers enumerateObjectsUsingBlock:^(FSQLocationResolverCompletionHandler handler, BOOL *stop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(self.currentLocation,self.error);
		});
	}];
	[_completionHandlers removeAllObjects];
	
	self.resolving = NO;
}




@end
