//
//  FSQKeyObserver_Protected.h
//  FivesquareKit
//
//  Created by John Clayton on 10/31/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import <FivesquareKit/FivesquareKit.h>

@interface FSQKeyObserver ()

- (id) onKeyPathChange:(NSString *)keyPath do:(void(^)(id value))block;
- (void) removeObservationBlock:(id)observation;

@end
