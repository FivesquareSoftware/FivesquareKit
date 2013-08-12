//
//  NSDictionary+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 2/5/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSDictionary+FSQFoundation.h"
#import "NSObject+FSQFoundation.h"

@implementation NSDictionary (FSQFoundation)

+ (BOOL) isEmpty:(id)obj {
	BOOL isEmpty = [NSObject isEmpty:obj];
	if (isEmpty) {
		return isEmpty;
	}
	
	return [obj count] == 0;
}

+ (BOOL) isNotEmpty:(id)obj {
	return NO == [self isEmpty:obj];
}

- (BOOL) hasKey:(id)key {
	NSArray *keys = [self allKeys];
	return [keys containsObject:key];
}

- (NSString *) stringValue {
	NSMutableString *stringValue = [NSMutableString new];
	NSArray *sortedKeys = [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj1 compare:obj2];
	}];
	[sortedKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
		[stringValue appendFormat:@":%@:%@:",@([key hash]),@([[self objectForKey:key] hash])];
	}];
	return stringValue;
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


