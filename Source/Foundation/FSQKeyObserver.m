//
//  FSQKeyObserver.m
//  FivesquareKit
//
//  Created by John Clayton on 12/31/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeyObserver.h"

#import <objc/runtime.h>
#import "FSQKeyObservation.h"

static const NSString *kNSObject_FSQFoundation_KeyObserver = @"NSObject_FSQFoundation_KeyObserver";


@implementation FSQKeyObserver
@dynamic observedKeyPaths;
- (NSSet *) observedKeyPaths {
    NSSet *keyPaths = [_observations valueForKey:@"keyPath"];
    return keyPaths;
}

+ (id) withObject:(id)observedObject {
    FSQKeyObserver *observer = objc_getAssociatedObject(observedObject, &kNSObject_FSQFoundation_KeyObserver);
    if (nil == observer) {
        observer = [FSQKeyObserver new];
        observer.observedObject = observedObject;
        objc_setAssociatedObject(observedObject, &kNSObject_FSQFoundation_KeyObserver, observer, OBJC_ASSOCIATION_RETAIN);
    }
    return observer;
}

- (void) dealloc {
    [self.observedKeyPaths enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [_observedObject removeObserver:self forKeyPath:obj];
    }];
}

- (id)init {
    self = [super init];
    if (self) {
        _observations = [NSMutableSet new];
    }
    return self;
}

- (id) onKeyPathChange:(NSString *)keyPath do:(void(^)(id value))block {
    FSQKeyObservation *observation = [FSQKeyObservation new];
    observation.keyPath = keyPath;
    observation.block = block;
    if (NO == [self.observedKeyPaths containsObject:keyPath]) {
        [_observedObject addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
    [_observations addObject:observation];
    return observation;
}

- (void) removeObservationBlock:(id)observation {
    FSQKeyObservation *keyPathObservation = observation;
    [_observations removeObject:observation];
    if (NO == [self.observedKeyPaths containsObject:keyPathObservation.keyPath]) {
        [_observedObject removeObserver:self forKeyPath:keyPathObservation.keyPath];
    }
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    NSSet *matchingObservations = [_observations objectsPassingTest:^BOOL(FSQKeyObservation *observation, BOOL *stop) {
        return [observation.keyPath isEqualToString:keyPath];
    }];
    [matchingObservations enumerateObjectsUsingBlock:^(FSQKeyObservation *observation, BOOL *stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            observation.block(newValue);
        });
    }];
}

@end
