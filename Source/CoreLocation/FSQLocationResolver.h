//
//  FSQLocationResolver.h
//  FivesquareKit
//
//  Created by John Clayton on 6/23/2008.
//  Copyright Fivesquare Software, LLC 2008. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class FSQLocationResolver;
typedef void (^FSQLocationResolverLocationUpdateHandler)(CLLocation *location, NSError *error);
typedef void (^FSQLocationResolverRegionUpdateHandler)(CLRegion *region, NSError *error);

extern NSString *kFSQLocationResolverStoppedUpdatingNotification;
extern NSString *kFSQLocationResolverKeyLocation;
extern NSString *kFSQLocationResolverKeyError;
extern NSString *kFSQLocationResolverKeyAborted; ///< Whether the resolution timed out or not

extern NSTimeInterval kFSQLocationResolverInfiniteTimeInterval;


@interface FSQLocationResolver : NSObject <CLLocationManagerDelegate> 

@property (nonatomic, strong) id identifier;
@property (nonatomic) CLActivityType activityType;

@property (getter = isResolving) BOOL resolving;
@property BOOL aborted; ///< YES when the timeout occurs before accuracy was achieved
@property BOOL initialFixFailed; ///< YES when the initial fix timeout occurs before an update occurred
@property (getter = isMonitoringSignificantChanges) BOOL monitoringSignificantChanges;


@property (strong) CLLocation *currentLocation; ///< The best effort location
@property (strong) CLLocation *lastGoodLocation; ///< The best effort location
@property (strong) NSError *error; ///< The error that occurred during last resolution


@property (nonatomic) NSTimeInterval resolutionTimeout;
@property (nonatomic) NSTimeInterval initialFixTimeout;

// If the location resolver is resolving without a timeout. If the hardware supports it, the receiver will pause locastion updates automatically depending on conditions when this is YES. Otherwise, updates are never paused until the timeout is reached.
@property (nonatomic,readonly) BOOL resolvingContinuously;

@property (nonatomic, readonly) CLAuthorizationStatus authorizationStatus;


- (BOOL) requestAuthorizationWithCompletionHandler:(void(^)(BOOL authorized))handler;
- (BOOL) requestAuthorizationWhenInUseWithCompletionHandler:(void(^)(BOOL authorized))handler;


/** Starts updating the current location, accurate to the provided accuracy, and stops even if the desired accuracy has not been achieved if #timeout has been reached. Callers should subscribe to the receiver's kFSQLocationResolverCompletedResolutionNotification notification to learn about the results of the update. The notification's user info will contain the value of the receiver's current location, any error that occurred and whether or not the resolution timed out before the desired accuracy was acheived.
 *
 *  @returns NO if location services are not available, which can include the situation where the user has denied access. 
 *  @returns immediately with YES if the receiver is already resolving.
 */
- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy within:(NSTimeInterval)timeout;

/** Like #resolveLocationAccurateTo:givingUpAfter:, but allows the caller to supply a handler bock along with the other parameters. This block will be called on the main queue to that it's safe to update UI from the handler.
 *  @param handler is added to a collection of handlers to be invoked if the resolver is already resolving.
 *  @see resolveLocationAccurateTo:givingUpAfter: for a discussion of return values.
 *  @note Notifications are also sent in addition to the handler blocks being invoked. 
 */
- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy within:(NSTimeInterval)timeout completionHandler:(FSQLocationResolverLocationUpdateHandler)handler;
- (BOOL) resolveLocationContinuouslyPausingAutomaticallyAccurateTo:(CLLocationAccuracy)accuracy initialFixWithin:(NSTimeInterval)initialTimeout distanceFilter:(CLLocationDistance)distanceFilter updateHandler:(FSQLocationResolverLocationUpdateHandler)handler;

/** Stops location updates and removes all completion handlers. */
- (void) stopResolving;


- (BOOL) onSignificantLocationChange:(FSQLocationResolverLocationUpdateHandler)onLocationChange;
- (BOOL) onSignificantLocationChange:(FSQLocationResolverLocationUpdateHandler)onLocationChange initialFixWithin:(NSTimeInterval)initialTimeout;
- (void) stopMonitoringSignificantLocationChange;

- (BOOL) startMonitoringForRegion:(CLRegion *)region onEnter:(FSQLocationResolverRegionUpdateHandler)onEnter onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure;
- (BOOL) startMonitoringForRegion:(CLRegion *)region onExit:(FSQLocationResolverRegionUpdateHandler)onExit onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure;
- (BOOL) startMonitoringForRegion:(CLRegion *)region onBegin:(FSQLocationResolverRegionUpdateHandler)onBegin onEnter:(FSQLocationResolverRegionUpdateHandler)onEnter onExit:(FSQLocationResolverRegionUpdateHandler)onExit  onFailure:(FSQLocationResolverRegionUpdateHandler)onFailure;

- (void) stopMonitoringRegion:(CLRegion *)region;

@end
