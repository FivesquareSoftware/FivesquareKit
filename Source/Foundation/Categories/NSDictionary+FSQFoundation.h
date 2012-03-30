//
//  NSDictionary+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 2/5/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FSQFoundation)

- (NSDictionary *) deepCopy;
- (NSMutableDictionary *) mutableDeepCopy;

- (id) objectMatchingPredicate:(NSPredicate *)predicate;

@end
