//
//  FSQKeyObserver.h
//  FivesquareKit
//
//  Created by John Clayton on 12/31/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQKeyObserver : NSObject
@property (nonatomic, weak) id observedObject;
@property (nonatomic, strong) NSMutableSet *observations;
@property (nonatomic, readonly) NSSet *observedKeyPaths;

+ (id) withObject:(id)observedObject;

- (id) onKeyPathChange:(NSString *)key do:(void(^)(id value))block;
- (void) removeObservationBlock:(id)observation;

@end
