//
//  NSObject+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 6/28/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSQKeyObserver.h"

@interface NSObject (FSQFoundation)

+ (BOOL) isEmpty:(id)obj; //< @returns YES if obj == nil || [NSNull null]
+ (BOOL) isNotEmpty:(id)obj;

#if (TARGET_OS_IPHONE)
+ (NSString *)className;
- (NSString *)className;
#endif

- (BOOL) setValue:(id)value forKeyPath:(NSString *)keyPath error:(NSError **)error;
- (id) valueForKeyPath:(NSString *)keyPath error:(NSError **)error;
- (BOOL) mapFromObject:(NSObject *)source error:(NSError **)error;

- (id) onKeyPathChange:(NSString *)keyPath do:(void(^)(id value))block;
- (void) removeObservationBlock:(id)observation;

@end
