//
//  FSQKeyObserver.m
//  FivesquareKit
//
//  Created by John Clayton on 12/31/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeyObserver.h"

#import "FSQKeyObservation.h"
#import "FSQLogging.h"
#import "FSQRuntime.h"


static const NSString *kNSObject_FSQFoundation_KeyObserver = @"NSObject_FSQFoundation_KeyObserver";


@interface FSQKeyObserver ()
@property (nonatomic, strong) NSMutableSet *observations;
@end

@implementation FSQKeyObserver

@dynamic observedKeyPaths;
- (NSSet *) observedKeyPaths {
    NSSet *keyPaths = [_observations valueForKey:@"keyPath"];
    return keyPaths;
}


- (void) dealloc {
	objc_setAssociatedObject(_observedObject, &kNSObject_FSQFoundation_KeyObserver, nil, OBJC_ASSOCIATION_ASSIGN);
}

- (id)init {
    self = [super init];
    if (self) {
//        _observations = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:1];

		CFSetCallBacks scb = { 0, NULL, NULL, CFCopyDescription, CFEqual };
		//!!!: should probably use a CFMutableSet here instead of having to check the contents of the array
		CFMutableSetRef setRef = CFSetCreateMutable(NULL, 0, &scb);

		_observations = (NSMutableSet *)CFBridgingRelease(setRef);
    }
    return self;
}

+ (id) withObject:(id)observedObject {
	FSQKeyObserver *observer = objc_getAssociatedObject(observedObject, &kNSObject_FSQFoundation_KeyObserver);
	if (nil == observer) {
		observer = [FSQKeyObserver new];
		observer.observedObject = observedObject;
		objc_setAssociatedObject(observedObject, &kNSObject_FSQFoundation_KeyObserver, observer, OBJC_ASSOCIATION_ASSIGN);
	}
	return observer;
}

+ (id) object:(id)observedObject onKeyPathChange:(NSString *)key do:(void(^)(id value))block {
	FSQKeyObserver *observer = [FSQKeyObserver withObject:observedObject];
	return [observer onKeyPathChange:key do:block];
}

+ (void) object:(id)observedObject removeObservationBlock:(id)observation {
	FSQKeyObserver *observer = [FSQKeyObserver withObject:observedObject];
	[observer removeObservationBlock:observation];
}

- (id) onKeyPathChange:(NSString *)keyPath do:(void(^)(id value))block {
    FSQKeyObservation *observation = [FSQKeyObservation new];
	observation.keyPathObserver = self;
    observation.keyPath = keyPath;
    observation.block = block;
    if (NO == [self.observedKeyPaths containsObject:keyPath]) {
        [_observedObject addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
    [_observations addObject:observation];
    return observation;
}

- (void) removeObservationBlock:(id)observation {
	if (nil == observation) {
		return;
	}
    FSQKeyObservation *keyPathObservation = observation;
	if (NO == [_observations containsObject:keyPathObservation]) {
		return;
	}
	[_observations removeObject:observation];
    if (NO == [self.observedKeyPaths containsObject:keyPathObservation.keyPath]) { // Observation was the last one, remove key path observation
        [_observedObject removeObserver:self forKeyPath:keyPathObservation.keyPath];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    NSSet *matchingObservations = [_observations objectsPassingTest:^BOOL(FSQKeyObservation *observation, BOOL *stop) {
        return [observation.keyPath isEqualToString:keyPath];
    }];

	for (FSQKeyObservation *observation in matchingObservations) {
		dispatch_async(dispatch_get_main_queue(), ^{
			observation.block(newValue);
		});
	}
}

@end
