//
//  FSQLocationResolver.m
//  FivesquareKit
//
//  Created by John Clayton on 6/23/2008.
//  Copyright Fivesquare Software, LLC 2008. All rights reserved.
//

#import "FSQLocationService.h"

#import "FSQLogging.h"
#import "FSQMacros.h"


#define kLocationLoggingEnabled DEBUG && 1
#define LocLog(frmt, ...) { FSQWeakSelf(self_); FLogMarkIf(kLocationLoggingEnabled, ([NSString stringWithFormat:@"LOCATION.%@",self_.identifier]) , frmt, ##__VA_ARGS__); }



NSString *kFSQLocationResolverStoppedUpdatingNotification = @"FSQLocationResolverStoppedUpdatingNotification";
NSString *kFSQLocationResolverKeyLocation = @"Location";
NSString *kFSQLocationResolverKeyError = @"Error";
NSString *kFSQLocationResolverKeyAborted = @"Aborted";

NSTimeInterval kFSQLocationResolverInfiniteTimeInterval = -1;

#define kFSQLocationResolverAccuracyBest 5

@interface FSQLocationService()

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) void(^authorizationAlwaysCompletionHandler)(BOOL authorized);
@property (nonatomic, copy) void(^authorizationWhenInUseCompletionHandler)(BOOL authorized);

@property (nonatomic, strong) NSDate *locationUpdatesStartedOn;
@property (nonatomic, strong) NSTimer *timedResolutionAbortTimer;
@property (nonatomic, strong) NSTimer *initialFixTimer;
@property (nonatomic, strong) NSMutableSet *locationUpdateHandlers;

@property (readwrite, strong) CLLocation *currentLocation;
@property (readwrite, strong) CLLocation *lastGoodLocation;
@property (readwrite, strong) CLLocation *lastUpdatedLocation;

@property (readwrite, strong) NSError *error;

@property (nonatomic, strong) NSMutableDictionary *regionBeginHandlersByIdentifier;
@property (nonatomic, strong) NSMutableDictionary *regionEnterHandlersByIdentifier;
@property (nonatomic, strong) NSMutableDictionary *regionExitHandlersByIdentifier;
@property (nonatomic, strong) NSMutableDictionary *regionFailureHandlersByIdentifier;

- (void) timedResolutionTimeLimitReached:(NSTimer *)timer;
- (void) initialFixTimeLimitReached:(NSTimer *)timer;

@end


@implementation FSQLocationService


// ========================================================================== //

#pragma mark - Properties

#if TARGET_OS_IPHONE
@dynamic activityType;
- (void) setActivityType:(CLActivityType)activityType {
	self.locationManager.activityType = activityType;
}

- (CLActivityType) activityType {
	return self.locationManager.activityType;
}
#endif

@dynamic resolving;
- (BOOL) isResolving {
	return (_serviceTypeMask&FSQLocationServiceTypeResolvingLocation) == FSQLocationServiceTypeResolvingLocation;
}

- (void) setResolving:(BOOL)resolving {
	_serviceTypeMask|= (resolving ? FSQLocationServiceTypeResolvingLocation : ~FSQLocationServiceTypeResolvingLocation);
}

@dynamic monitoringSignificantChanges;
- (BOOL) isMonitoringSignificantChanges {
	return (_serviceTypeMask&FSQLocationServiceTypeMonitoringSignificantChanges) == FSQLocationServiceTypeMonitoringSignificantChanges;
}

- (void) setMonitoringSignificantChanges:(BOOL)monitoringSignificantChanges {
	_serviceTypeMask|= (monitoringSignificantChanges ? FSQLocationServiceTypeMonitoringSignificantChanges : ~FSQLocationServiceTypeMonitoringSignificantChanges);
}

@dynamic monitoringRegions;
- (BOOL) isMonitoringRegions {
	return (_serviceTypeMask&FSQLocationServiceTypeMonitoringRegions) == FSQLocationServiceTypeMonitoringRegions;
}

- (void) setMonitoringRegions:(BOOL)monitoringRegions {
	_serviceTypeMask|= (monitoringRegions ? FSQLocationServiceTypeMonitoringRegions : ~FSQLocationServiceTypeMonitoringRegions);
}

- (CLLocationManager *) locationManager {
    if(_locationManager == nil) {
        CLLocationManager *locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        _locationManager = locationManager;
		self.currentLocation = _locationManager.location;
		self.lastGoodLocation = _currentLocation;
    }
    return _locationManager;
}

- (BOOL) resolvingContinuously {
	BOOL resolvingContinuously = (_resolutionTimeout == kFSQLocationResolverInfiniteTimeInterval);
	return resolvingContinuously;
}

@dynamic authorizationStatus;
- (CLAuthorizationStatus) authorizationStatus {
	return [CLLocationManager authorizationStatus];
}

@dynamic locationManagerLocation;
- (CLLocation *) locationManagerLocation {
	return _locationManager.location;
}

@dynamic monitoredRegions;
- (NSSet *) monitoredRegions {
	return _locationManager.monitoredRegions;
}

// ========================================================================== //

#pragma mark - Object



- (void)dealloc {
	[_locationUpdateHandlers removeAllObjects];
	if([self.timedResolutionAbortTimer isValid]) {
		[self.timedResolutionAbortTimer invalidate];
	}
	if([self.initialFixTimer isValid]) {
		[self.initialFixTimer invalidate];
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
		
		_identifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}


- (NSString *)description {
	return [NSString stringWithFormat:@"%@ identifier : %@", [super description],_identifier];
}


// ========================================================================== //

#pragma mark - Public

#if TARGET_OS_IPHONE
- (BOOL) requestAuthorizationWithCompletionHandler:(void(^)(BOOL authorized))handler {
	CLAuthorizationStatus status = self.authorizationStatus;
	BOOL authorizing = (status == kCLAuthorizationStatusNotDetermined);
	if (authorizing) {
		_authorizationAlwaysCompletionHandler = handler;
		[self.locationManager requestAlwaysAuthorization];
	}
	else if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(status == kCLAuthorizationStatusAuthorizedAlways);
		});
	}
	return authorizing;
}

- (BOOL) requestAuthorizationWhenInUseWithCompletionHandler:(void(^)(BOOL authorized))handler {
	CLAuthorizationStatus status = self.authorizationStatus;
	BOOL authorizing = (status == kCLAuthorizationStatusNotDetermined);
	if (authorizing) {
		_authorizationWhenInUseCompletionHandler = handler;
		[self.locationManager requestWhenInUseAuthorization];
	}
	else if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(status == kCLAuthorizationStatusAuthorizedWhenInUse);
		});
	}
	return authorizing;
}
#endif


- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy within:(NSTimeInterval)timeout {
	return [self resolveLocationAccurateTo:accuracy within:timeout completionHandler:nil];
}

- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy within:(NSTimeInterval)timeout completionHandler:(FSQLocationResolverLocationUpdateHandler)handler {
	return [self resolveLocationAccurateTo:accuracy within:timeout initialFixWithin:kFSQLocationResolverInfiniteTimeInterval distanceFilter:kCLDistanceFilterNone completionHandler:handler];
}

- (BOOL) resolveLocationContinuouslyPausingAutomaticallyAccurateTo:(CLLocationAccuracy)accuracy initialFixWithin:(NSTimeInterval)initialTimeout distanceFilter:(CLLocationDistance)distanceFilter updateHandler:(FSQLocationResolverLocationUpdateHandler)handler {
	return [self resolveLocationAccurateTo:accuracy within:kFSQLocationResolverInfiniteTimeInterval initialFixWithin:initialTimeout distanceFilter:distanceFilter completionHandler:handler];
}

- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy within:(NSTimeInterval)timeout initialFixWithin:(NSTimeInterval)initialTimeout distanceFilter:(CLLocationDistance)distanceFilter completionHandler:(FSQLocationResolverLocationUpdateHandler)handler {

	if (kCLAuthorizationStatusAuthorized != [CLLocationManager authorizationStatus]) return NO;
	if (NO == [CLLocationManager locationServicesEnabled]) return NO;
	
	if (self.isResolving) {
		// Since each resolution session has its own configuration we refuse to start another one until the current session is stopped
		return NO;
	}

	if (self.timedResolutionAbortTimer) {
		[self.timedResolutionAbortTimer invalidate];
		self.timedResolutionAbortTimer = nil;
	}

	[_locationUpdateHandlers addObject:[handler copy]];


	self.resolving = YES;
	self.aborted = NO;
	
//	self.completionHandler = handler;
	
	self.locationUpdatesStartedOn = [NSDate date];
    self.locationManager.desiredAccuracy = accuracy;
	self.locationManager.distanceFilter = distanceFilter;
	self.resolutionTimeout = timeout;
	self.initialFixTimeout = initialTimeout;
	
#if TARGET_OS_IPHONE
	self.locationManager.pausesLocationUpdatesAutomatically = self.resolvingContinuously;
#endif

	// Let's at least see make sure there is a value, even if bogus
	self.currentLocation = self.locationManager.location;

//	LocLog(@"locationManager.pausesLocationUpdatesAutomatically: %@",@(self.locationManager.pausesLocationUpdatesAutomatically));
	[self.locationManager startUpdatingLocation];
	
	if (self.timedResolutionAbortTimer) {
		[self.timedResolutionAbortTimer invalidate];
		self.timedResolutionAbortTimer = nil;
	}
	if (timeout != kFSQLocationResolverInfiniteTimeInterval) {
		self.timedResolutionAbortTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timedResolutionTimeLimitReached:) userInfo:nil repeats:NO];
	}
	
	if (self.initialFixTimer) {
		[self.initialFixTimer invalidate];
		self.initialFixTimer = nil;
	}
	if (initialTimeout != kFSQLocationResolverInfiniteTimeInterval) {
		self.initialFixTimer = [NSTimer scheduledTimerWithTimeInterval:initialTimeout target:self selector:@selector(initialFixTimeLimitReached:) userInfo:nil repeats:NO];
	}

	// experimenting with getting a cached location
	//	self.currentLocation = self.locationManager.location;
	
	return YES;
}

- (void) stopResolving {
	[self.locationManager stopUpdatingLocation];

	if (self.timedResolutionAbortTimer) {
		[self.timedResolutionAbortTimer invalidate];
		self.timedResolutionAbortTimer = nil;
	}
	
	[_locationUpdateHandlers removeAllObjects];
	
	self.resolving = NO;
}

- (BOOL) onSignificantLocationChange:(FSQLocationResolverLocationUpdateHandler)onLocationChange {
	return [self onSignificantLocationChange:onLocationChange initialFixWithin:kFSQLocationResolverInfiniteTimeInterval];
}

- (BOOL) onSignificantLocationChange:(FSQLocationResolverLocationUpdateHandler)onLocationChange initialFixWithin:(NSTimeInterval)initialTimeout {
	if (kCLAuthorizationStatusAuthorized != [CLLocationManager authorizationStatus]) return NO;
	if (NO == [CLLocationManager significantLocationChangeMonitoringAvailable]) return NO;
	[_locationUpdateHandlers addObject:[onLocationChange copy]];
	if (self.isMonitoringSignificantChanges) {
		// Invoke the new listener with our current location since a new event may be a while coming, the initial fix timer remains the same so as not to invalidate the previous callers expectations
		dispatch_async(dispatch_get_main_queue(), ^{
			onLocationChange(self.currentLocation,nil);
		});
		return YES;
	}
	self.monitoringSignificantChanges = YES;
	
	if (self.isResolving) {
		[self stopResolving];
	}

	self.initialFixTimeout = initialTimeout;
	
	self.locationUpdatesStartedOn = [NSDate date];
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	// Let's at least see make sure there is a value, even if bogus
	self.currentLocation = self.locationManager.location;

	[self.locationManager startMonitoringSignificantLocationChanges];
	
	if (self.initialFixTimer) {
		[self.initialFixTimer invalidate];
		self.initialFixTimer = nil;
	}
	if (initialTimeout != kFSQLocationResolverInfiniteTimeInterval) {
		self.initialFixTimer = [NSTimer scheduledTimerWithTimeInterval:initialTimeout target:self selector:@selector(initialFixTimeLimitReached:) userInfo:nil repeats:NO];
	}
	
	return YES;
}

- (void) stopMonitoringSignificantLocationChange {
	[self.locationManager stopMonitoringSignificantLocationChanges];
	[_locationUpdateHandlers removeAllObjects];
	self.monitoringSignificantChanges = NO;
}

- (BOOL) startMonitoringForRegion:(CLRegion *)region onEnter:(FSQLocationResolverRegionUpdateHandler)onEnter onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure {
	return [self startMonitoringForRegion:region onBegin:nil onEnter:onEnter onExit:nil onFailure:onFailure];
}

- (BOOL) startMonitoringForRegion:(CLRegion *)region onExit:(FSQLocationResolverRegionUpdateHandler)onExit onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure {
	return [self startMonitoringForRegion:region onBegin:nil onEnter:nil onExit:onExit onFailure:onFailure];
}

- (BOOL) startMonitoringForRegion:(CLRegion *)region onBegin:(FSQLocationResolverRegionUpdateHandler)onBegin onEnter:(FSQLocationResolverRegionUpdateHandler)onEnter onExit:(FSQLocationResolverRegionUpdateHandler)onExit  onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure {
	NSParameterAssert(region != nil);
	if (kCLAuthorizationStatusAuthorized != [CLLocationManager authorizationStatus]) return NO;
	if (nil == region) return NO;
	if (NO == [CLLocationManager isMonitoringAvailableForClass:[region class]]) return NO;

	if (onBegin) {
		_regionBeginHandlersByIdentifier[region.identifier] = [onBegin copy];
	}
	if (onEnter) {
		_regionEnterHandlersByIdentifier[region.identifier] = [onEnter copy];
	}
	if (onExit) {
		_regionExitHandlersByIdentifier[region.identifier] = [onExit copy];
	}
	if (onFailure) {
		_regionFailureHandlersByIdentifier[region.identifier] = [onFailure copy];
	}
	[self.locationManager startMonitoringForRegion:region];

	self.monitoringRegions = YES;

	return YES;
}

- (void) stopMonitoringRegion:(CLRegion *)region {
	[self.locationManager stopMonitoringForRegion:region];
	[_regionBeginHandlersByIdentifier removeObjectForKey:region.identifier];
	[_regionEnterHandlersByIdentifier removeObjectForKey:region.identifier];
	[_regionExitHandlersByIdentifier removeObjectForKey:region.identifier];
	[_regionFailureHandlersByIdentifier removeObjectForKey:region.identifier];

	self.monitoringRegions = [_regionBeginHandlersByIdentifier count] > 0;
}



// ========================================================================== //

#pragma mark - CLLocationManagerDelegate

//- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    LocLog(@"didUpdateLocations:%@",locations);
	
	CLLocation *newLocation = [locations lastObject];
	LocLog(@"newLocation:%@",newLocation);

	NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval fromWhenUpdatesStarted = [eventDate timeIntervalSinceDate:self.locationUpdatesStartedOn];
	LocLog(@"fromWhenUpdatesStarted: %@",@(fromWhenUpdatesStarted));
	
	if (self.isResolving && fromWhenUpdatesStarted <= 0) { // this update was cached before we started resolving, other modes are still interested in this
		LocLog(@"Stale location while resolving, will keep trying ..");
		return;
	}
	
	LocLog(@"newLocation.horizontalAccuracy:%f",newLocation.horizontalAccuracy);
	if (newLocation.horizontalAccuracy < 0) { // an invalid location
		LocLog(@"No horizontal accuracy, will keep trying ..");
		return;
	}

	self.lastUpdatedLocation = newLocation;
	
	// If we got at least as good a location update consider this test to pass since a new location may actually be as good as our last one (i.e. our current one may actually be pretty good)

	LocLog(@"currentLocation.horizontalAccuracy:%f",self.currentLocation.horizontalAccuracy);
	LocLog(@"locationManager.desiredAccuracy:%f",self.locationManager.desiredAccuracy);

	LocLog(@"currentLocation:%@",self.currentLocation);

	CLLocationDistance locationDelta FSQ_MAYBE_UNUSED = [self.currentLocation distanceFromLocation:newLocation];
	LocLog(@"locationDelta: %@",@(locationDelta));

	LocLog(@"Got decent location, setting it to last good location location");
	self.lastGoodLocation = newLocation;

	if (self.initialFixTimer) {
		[self.initialFixTimer invalidate];
		self.initialFixTimer = nil;
	}


	LocLog(@"kCLLocationAccuracyBestForNavigation:%f",kCLLocationAccuracyBestForNavigation);
	LocLog(@"kCLLocationAccuracyBest:%f",kCLLocationAccuracyBest);

	// When resolving we checl accuracy
	if (self.isResolving) {
		// When caller has set desired accuracy to one of the "best" values, they will actually be negative, which in a location update would indicate invalid, so just check for <= the kFSQLocationResolverAccuracyBest, which seems to be the best possible accuracy we get
		if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy || (self.locationManager.desiredAccuracy < 0 && newLocation.horizontalAccuracy <= kFSQLocationResolverAccuracyBest) ) {
			LocLog(@"Got a good enough location: newLocation.horizontalAccuracy:%f",newLocation.horizontalAccuracy);
			self.currentLocation = newLocation;
#if TARGET_OS_IPHONE
			if (self.resolvingContinuously) {
				LocLog(@"locationManager.pausesLocationUpdatesAutomatically: %@",@(self.locationManager.pausesLocationUpdatesAutomatically));
				LocLog(@"Running continuously, handling location change");
				[self handleLocationUpdate];
				return;
			}
#endif
			LocLog(@"Stopping updates");
			[self.locationManager stopUpdatingLocation];
			[self handleFailureOrCompletion];
		}
		else {
			LocLog(@"Location not good enough, will keep trying ..");
		}
	}
	// For other service types like sigloc or regions, we want everything the system sends us
	else {
		LocLog(@"Handling significant location change");
		self.currentLocation = newLocation;
		[self handleLocationUpdate];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) { // Unknown means we could recover
		[self.locationManager stopUpdatingLocation];
		self.currentLocation = self.locationManager.location; // use the best location we can
		self.error = error;
		[self handleFailureOrCompletion];
	}
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	LocLog(@"didEnterRegion:%@",region);
	FSQLocationResolverRegionUpdateHandler handler = _regionEnterHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,nil);
		});
	}
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	LocLog(@"didExitRegion:%@",region);
	FSQLocationResolverRegionUpdateHandler handler = _regionExitHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,nil);
		});
	}
}

- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
	LocLog(@"didStartMonitoringForRegion:%@",region);
	FSQLocationResolverRegionUpdateHandler handler = _regionBeginHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,nil);
		});
	}
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	LocLog(@"monitoringDidFailForRegion:%@ withError: %@",region,error);
	FSQLocationResolverRegionUpdateHandler handler = _regionFailureHandlersByIdentifier[region.identifier];
	if (handler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(region,error);
		});
	}
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if (status == kCLAuthorizationStatusNotDetermined) {
		return;
	}
#if TARGET_OS_IPHONE
	if (_authorizationAlwaysCompletionHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_authorizationAlwaysCompletionHandler(status == kCLAuthorizationStatusAuthorizedAlways);
			_authorizationAlwaysCompletionHandler = nil;
		});
	}
	if (_authorizationWhenInUseCompletionHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_authorizationWhenInUseCompletionHandler(status == kCLAuthorizationStatusAuthorizedWhenInUse);
			_authorizationWhenInUseCompletionHandler = nil;
		});
	}
#endif
}


// ========================================================================== //

#pragma mark - Timeouts


- (void) timedResolutionTimeLimitReached:(NSTimer *)timer {
	self.aborted = YES;
	self.resolutionTimeout = 0;
	
	[self.locationManager stopUpdatingLocation];	
	self.currentLocation = self.locationManager.location; // get the best location we can
	
	NSError *abortError = [NSError errorWithDomain:kCLErrorDomain code:kCLErrorLocationUnknown userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Timed out resolving location, using best effort location.", @"FSQLocationResolver timeout error description") }];
	self.error = abortError;
	
	LocLog(@"Timed resolution timeout reached, sending update with best effort location: %@",self.currentLocation);
	[self handleFailureOrCompletion];
}

- (void) initialFixTimeLimitReached:(NSTimer *)timer {
	self.initialFixFailed = YES;
	self.initialFixTimeout = 0;
	self.currentLocation = self.locationManager.location; // get the best location we can
	LocLog(@"Initial fix timeout reached, sending update with best effort location: %@",self.currentLocation);
	[self handleLocationUpdate];
}

// ========================================================================== //

#pragma mark - Handlers

- (void) handleFailureOrCompletion {
	if (self.timedResolutionAbortTimer) {
		[self.timedResolutionAbortTimer invalidate];
		self.timedResolutionAbortTimer = nil;
	}
			
	NSMutableDictionary *info = [NSMutableDictionary new];
	if (self.currentLocation) {
		[info setObject:self.currentLocation forKey:kFSQLocationResolverKeyLocation];
	}
	if (self.error) {
		[info setObject:self.error forKey:kFSQLocationResolverKeyError];
	}
	[info setObject:@(self.aborted) forKey:kFSQLocationResolverKeyAborted];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kFSQLocationResolverStoppedUpdatingNotification object:self userInfo:info];
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
		self.lastGoodLocation = self.currentLocation;
	}
	if (self.error) {
		[info setObject:self.error forKey:kFSQLocationResolverKeyError];
	}
	[info setObject:@(self.aborted) forKey:kFSQLocationResolverKeyAborted];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kFSQLocationResolverStoppedUpdatingNotification object:self userInfo:info];
	[_locationUpdateHandlers enumerateObjectsUsingBlock:^(FSQLocationResolverLocationUpdateHandler handler, BOOL *stop) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(self.currentLocation,self.error);
		});
	}];
}

@end
