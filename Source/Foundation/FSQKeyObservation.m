//
//  FSQKeyObservation.m
//  FivesquareKit
//
//  Created by John Clayton on 12/31/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeyObservation.h"

#import "FSQKeyObserver+Protected.h"

@implementation FSQKeyObservation

- (void)dealloc {
	[_keyPathObserver removeObservationBlock:self];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@  object : %@, keyPath : %@, block : %@",[super description],_keyPathObserver.observedObject, _keyPath, _block];
}

@dynamic key;
- (NSString *) key {
    return [[_keyPath componentsSeparatedByString:@"."] lastObject];
}

@end
