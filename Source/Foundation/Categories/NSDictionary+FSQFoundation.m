//
//  NSDictionary+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 2/5/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSDictionary+FSQFoundation.h"

@implementation NSDictionary (FSQFoundation)

+ (BOOL) isEmpty:(id)obj {
	if (nil == obj) {
		return YES;
	}
	if ([NSNull null] == obj) {
		return YES;
	}
	
	return [obj count] == 0;
}

+ (BOOL) isNotEmpty:(id)obj {
	return NO == [self isEmpty:obj];
}

- (NSDictionary *) deepCopy {
    NSMutableDictionary *deepCopy = [[NSMutableDictionary alloc] init];
	for (NSString *key in self) {
		id value = [self valueForKey:key];
		[deepCopy setValue:[value copy] forKey:key];
	}
    return deepCopy;
}

- (NSMutableDictionary *) mutableDeepCopy {
	return (NSMutableDictionary *)[self deepCopy];
}

- (id) objectMatchingPredicate:(NSPredicate *)predicate {
	return [[[self allValues] filteredArrayUsingPredicate:predicate] lastObject];
}

@end

@implementation NSMutableDictionary (FSQFoundation)

- (void) setObjectIfNotNil:(id)obj forKey:(id<NSCopying>)key {
	if (obj) {
		[self setObject:obj forKey:key];
	}
}

@end


