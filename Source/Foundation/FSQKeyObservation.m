//
//  FSQKeyObservation.m
//  FivesquareKit
//
//  Created by John Clayton on 12/31/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeyObservation.h"

@implementation FSQKeyObservation
- (NSString *) description {
	return [NSString stringWithFormat:@"%@ {keyPath : %@, block : %@}",[super description],_keyPath,_block];
}

@dynamic key;
- (NSString *) key {
    return [[_keyPath componentsSeparatedByString:@"."] lastObject];
}

@end
