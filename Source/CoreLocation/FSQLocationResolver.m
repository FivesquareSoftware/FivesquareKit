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

NSTimeInterval kFSQLocationResolverInfiniteTimeInterval = -1;

#define kFSQLocationResolverAccuracyBest 5

@interface FSQLocationResolver()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDate *locationUpdatesStartedOn;
@property (nonatomic, strong) NSTimer *locationServicesAbortTimer;
//@property (nonatomic, copy) FSQLocationResolverCompletionHandler completionHandler;
@property (nonatomic, strong) NSMutableSet *locationUpdateHandlers;
@property (strong) CLLocation *lastUpdatedLocation; ///< The last location we got from the location manager. May or may/not be better than the best effort location.

@property (nonatomic, strong) NSMutableDictionary *regionBeginHandlersByIdentifier;
@property (nonatomic, strong) NSMutableDictionary *regionEnterHandlersByIdentifier;
@property (nonatomic, strong) NSMutableDictionary *regionExitHandlersByIdentifier;
@property (nonatomic, strong) NSMutableDictionary *regionFailureHandlersByIdentifier;

- (void) locationSearchTimeLimitReached:(NSTimer *)timer;

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
	[_locationUpdateHandlers removeAllObjects];
	if([self.locationServicesAbortTimer isValid]) {
		[self.locationServicesAbortTimer invalidate];
	}
}

- (id)init {
    self = [super init];
    if (self) {
        _locationUpdateHandlers = [NSMutableSet new];
		_regionBeginHandlersByIdentifier = [NSMutableDictionary new];
		_regionEnterHandlersByIdentifier = [NSMutableDictionary new];
		_regionExitHandlersByIdentifier = [NSMutableDictionary new];
		_regionFailureHandlersByIdentifier = [NSMutableDictionary new];
    }
    return self;
}



// ========================================================================== //

#pragma mark - Public



- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout {
	return [self resolveLocationAccurateTo:accuracy givingUpAfter:timeout completionHandler:nil];
}

- (BOOL) resolveLocationContinuouslyPausingAutomaticallyAccurateTo:(CLLocationAccuracy)accuracy updateHandler:(FSQLocationResolverLocationUpdateHandler)handler {
	return [self resolveLocationAccurateTo:accuracy givingUpAfter:kFSQLocationResolverInfiniteTimeInterval completionHandler:handler];
}

- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout completionHandler:(FSQLocationResolverLocationUpdateHandler)handler {
	
	if (NO == [CLLocationManager locationServicesEnabled]) return NO;
	
	[_locationUpdateHandlers addObject:[handler copy]];
	if (self.isResolving) return YES;
	
	self.resolving = YES;
	self.aborted = NO;
	
//	self.completionHandler = handler;
	
	self.locationUpdatesStartedOn = [NSDate date];
    self.locationManager.desiredAccuracy = accuracy;
#ifdef __IPHONE_6
	if ([self.locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
		self.locationManager.pausesLocationUpdatesAutomatically = (timeout == kFSQLocationResolverInfiniteTimeInterval);
	}
#endif
    [self.locationManager startUpdatingLocation];
	
	if (self.locationServicesAbortTimer) {
		[self.locationServicesAbortTimer invalidate];
		self.locationServicesAbortTimer = nil;
	}
	if (timeout != kFSQLocationResolverInfiniteTimeInterval) {
		self.locationServicesAbortTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(locationSearchTimeLimitReached:) userInfo:nil repeats:NO];
	}

	// experimenting with getting a cached location
	//	self.currentLocation = self.locationManager.location;
	
	return YES;
}

- (void) stopResolving {
	[self.locationManager stopUpdatingLocation];

	if (self.locationServicesAbortTimer) {
		[self.locationServicesAbortTimer invalidate];
		self.locationServicesAbortTimer = nil;
	}
	
	[_locationUpdateHandlers removeAllObjects];
	
	self.resolving = NO;
}

- (BOOL) onSignificantLocationChange:(FSQLocationResolverLocationUpdateHandler)onLocationChange {
	if (NO == [CLLocationManager locationServicesEnabled]) return NO;
	if (self.isMonitoringSignificantChanges) {
		[_locationUpdateHandlers addObject:[onLocationChange copy]];
	}
	if (self.isResolving) {
		[self stopResolving];
	}
	self.locationUpdatesStartedOn = [NSDate date];
	self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	[self.locationManager startMonitoringSignificantLocationChanges];
	self.monitoringSignificantChanges = YES;
	return YES;
}

- (void) stopMonitoringSignificantLocationChange {
	[self.locationManager stopMonitoringSignificantLocationChanges];
	[_locationUpdateHandlers removeAllObjects];
	self.monitoringSignificantChanges = NO;
}

- (BOOL) onEnterRegion:(CLRegion *)region do:(FSQLocationResolverRegionUpdateHandler)onEnter onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure {
	return [self startMonitoringForRegion:region onBegin:nil onEnter:onEnter onExit:nil onFailure:onFailure];
}

- (BOOL) onExitRegion:(CLRegion *)region do:(FSQLocationResolverRegionUpdateHandler)onExit onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure {
	return [self startMonitoringForRegion:region onBegin:nil onEnter:nil onExit:onExit onFailure:onFailure];
}

- (BOOL) startMonitoringForRegion:(CLRegion *)region onBegin:(FSQLocationResolverRegionUpdateHandler)onBegin onEnter:(FSQLocationResolverRegionUpdateHandler)onEnter onExit:(FSQLocationResolverRegionUpdateHandler)onExit  onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure {
	if (NO == [CLLocationManager locationServicesEnabled]) return NO;
	if (onEnter) {
		_regionEnterHandlersByIdentifier[region.identifier] = [onEnter copy];
	}
	if (onExit) {
		_regionExitHandlersByIdentifier[region.identifier] = [onExit copy];
	}
	return YES;
}

- (void) stopMonitoringRegion:(CLRegion *)region {
	[self.locationManager stopMonitoringForRegion:region];
	[_regionBeginHandlersByIdentifier removeObjectForKey:region.identifier];
	[_regionEnterHandlersByIdentifier removeObjectForKey:region.identifier];
	[_regionExitHandlersByIdentifier removeObjectForKey:region.identifier];
	[_regionFailureHandlersByIdentifier removeObjectForKey:region.identifier];
}



// ========================================================================== //

#pragma mark - CLLocationManagerDelegate

//- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    FLog(@"didUpdateToLocation:%@ fromLocation:%@",newLocation,oldLocation);
    FLog(@"didUpdateLocations:%@",locations);
	
	if (self.isMonitoringSignificantChanges) {
		[self handleLocationUpdate];
		return;
	}
	
	CLLocation *newLocation = [locations lastObject];
	
	NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval fromWhenUpdatesStarted = [eventDate timeIntervalSinceDate:self.locationUpdatesStartedOn];
//	FLog(@"fromWhenUpdatesStarted: %@",@(fromWhenUpdatesStarted));

	if (fromWhenUpdatesStarted <= 0) return; // this update was cached before we started resolving
	if (newLocation.horizontalAccuracy < 0) return; // an invalid location

	self.lastUpdatedLocation = newLocation;
	// If we got at least as good a location update consider this test to pass since a new location may actually be as good as our last one (i.e. our current one may actually be pretty good)
	if (self.currentLocation == nil || self.currentLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
		FLog(@"Got decent location, setting it to best effort location");
        self.currentLocation = newLocation;

		FLogSimple(@"newLocation.horizontalAccuracy:%f",newLocation.horizontalAccuracy);
		FLogSimple(@"locationManager.desiredAccuracy:%f",self.locationManager.desiredAccuracy);
		FLogSimple(@"kCLLocationAccuracyBestForNavigation:%f",kCLLocationAccuracyBestForNavigation);
		FLogSimple(@"kCLLocationAccuracyBest:%f",kCLLocationAccuracyBest);
		
		// When caller has set desired accuracy to one of the "best" values, they will actually be negative, which in a location update would indicate invalid, so just check for <= the kFSQLocationResolverAccuracyBest, which seems to be the best possible accuracy we get
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy || (self.locationManager.desiredAccuracy < 0 && newLocation.horizontalAccuracy <= kFSQLocationResolverAccuracyBest) ) {
			FLog(@"Got a good enough location: newLocation.horizontalAccuracy:%f",newLocation.horizontalAccuracy);
			self.currentLocation = newLocation;
#ifdef __IPHONE_6
			if (self.locationManager.pausesLocationUpdatesAutomatically) {
				[self handleLocationUpdate];
				return;
			}
#endif
			FLog(@"Stopping updates");
			[self.locationManager stopUpdatingLocation];
			[self handleResolutionCompletion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) { // Unknown means we could recover
		[self.locationManager stopUpdatingLocation];
		self.currentLocation = self.locationManager.location; // use the best location we can
		self.error = error;
		[self handleResolutionCompletion];
	}
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	FLogDebug(@"didEnterRegion:%@",region);
	FSQLocationResolverRegionUpdateHandler handler = _regionEnterHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,nil);
		});
	}
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	FLogDebug(@"didExitRegion:%@",region);
	FSQLocationResolverRegionUpdateHandler handler = _regionExitHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,nil);
		});
	}
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
	FLogDebug(@"didStartMonitoringForRegion:%@",region);
	FSQLocationResolverRegionUpdateHandler handler = _regionBeginHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,nil);
		});
	}
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	FLogDebug(@"monitoringDidFailForRegion:%@ withError: %@",region,error);
	FSQLocationResolverRegionUpdateHandler handler = _regionFailureHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,error);
		});
	}
}

// ========================================================================== //

#pragma mark - Timeout


- (void) locationSearchTimeLimitReached:(NSTimer *)timer {
	self.aborted = YES;
	[self.locationManager stopUpdatingLocation];	
	self.currentLocation = self.locationManager.location; // get the best location we can
	
	NSError *abortError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorLocationUnknown userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Timed out resolving location, using best effort location.", @"FSQLocationResolver timeout error description") }];
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
	
	if (NO == self.resolving) {
		return;
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
	[_locationUpdateHandlers enumerateObjectsUsingBlock:^(FSQLocationResolverLocationUpdateHandler handler, BOOL *stop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(self.currentLocation,self.error);
		});
	}];
	[_locationUpdateHandlers removeAllObjects];
	
	self.resolving = NO;
}

- (void) handleLocationUpdate {
	NSMutableDictionary *info = [NSMutableDictionary new];
	if (self.currentLocation) {
		[info setObject:self.currentLocation forKey:kFSQLocationResolverKeyLocation];
	}
	if (self.error) {
		[info setObject:self.error forKey:kFSQLocationResolverKeyError];
	}
	[info setObject:@(self.aborted) forKey:kFSQLocationResolverKeyAborted];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kFSQLocationResolverCompletedResolutionNotification object:self userInfo:info];
	[_locationUpdateHandlers enumerateObjectsUsingBlock:^(FSQLocationResolverLocationUpdateHandler handler, BOOL *stop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(self.currentLocation,self.error);
		});
	}];
}

@end
