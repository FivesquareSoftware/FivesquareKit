//
//  NSDictionary+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 2/5/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FSQFoundation)

+ (BOOL) isEmpty:(id)obj; //< @returns YES if obj == nil || [obj count] == 0
+ (BOOL) isNotEmpty:(id)obj;

- (BOOL) hasKey:(id)key;

- (NSDictionary *) deepCopy;
- (NSMutableDictionary *) mutableDeepCopy;

- (NSString *) stringValue;

- (id) objectMatchingPredicate:(NSPredicate *)predicate;

@end

@interface NSMutableDictionary (FSQFoundation)

- (void) setObjectIfNotNil:(id)obj forKey:(id<NSCopying>)key;

@end
