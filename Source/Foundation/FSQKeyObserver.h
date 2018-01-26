//
//  FSQKeyObserver.h
//  FivesquareKit
//
//  Created by John Clayton on 12/31/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQKeyObserver : NSObject
@property (nonatomic, strong) id observedObject;
//@property (nonatomic, readonly) NSSet *observations;
@property (nonatomic, readonly) NSSet *observedKeyPaths;


/** Returns an observation that is part of an object graph that retains the observed object. You must retain this object to keep the observation and release it when you are done. If you don't release it the observed object will leak. */
+ (id) object:(id)observedObject onKeyPathChange:(NSString *)key do:(void(^)(id value))block;
+ (void) object:(id)observedObject removeObservationBlock:(id)observation;



@end
