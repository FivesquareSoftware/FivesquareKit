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
typedef void (^FSQLocationResolverCompletionHandler)(CLLocation *location, NSError *error);

extern NSString *kFSQLocationResolverCompletedResolutionNotification;
extern NSString *kFSQLocationResolverKeyLocation;
extern NSString *kFSQLocationResolverKeyError;
extern NSString *kFSQLocationResolverKeyAborted; ///< Whether the resolution timed out or not


@interface FSQLocationResolver : NSObject <CLLocationManagerDelegate> 

@property (getter = isResolving) BOOL resolving;
@property BOOL aborted; ///< YES when the timeout occurs before accuracy was acheived
@property (strong) CLLocation *currentLocation; ///< The best effor location
@property (strong) NSError *error; ///< The error that occurred during last resolution


/** Starts updating the current location, accurate to the provided accuracy, and stops even if the desired accuracy has not been achieved if #timeout has been reached. Callers should subscribe to the receiver's kFSQLocationResolverCompletedResolutionNotification notification to learn about the results of the update. The notification's user info will contain the value of the receiver's current location, any error that occurred and whether or not the resolution timed out before the desired accuracy was acheived.
 *
 *  @returns NO if location services are not available, which can include the situation where the user has denied access. 
 *  @returns immediately with YES if the receiver is already resolving.
 */
- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout;

/** Like #resolveLocationAccurateTo:givingUpAfter:, but allows the caller to supply a handler bock along with the other parameters. This block will be called on the main queue to that it's safe to update UI from the handler.
 *  @param handler is added to a collection of handlers to be invoked if the resolver is already resolving.
 *  @see resolveLocationAccurateTo:givingUpAfter: for a discussion of return values.
 *  @note Notifications are also sent in addition to the handler blocks being invoked. 
 */
- (BOOL) resolveLocationAccurateTo:(CLLocationAccuracy)accuracy givingUpAfter:(NSTimeInterval)timeout completionHandler:(FSQLocationResolverCompletionHandler)handler;

@end
