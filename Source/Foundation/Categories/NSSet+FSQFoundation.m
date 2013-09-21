//
//  NSSet+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 9/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSSet+FSQFoundation.h"

#import "NSArray+FSQFoundation.h"
#import "NSObject+FSQFoundation.h"

@implementation NSSet (FSQFoundation)

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

- (id) randomObject {
	return [[self allObjects] anyObject];
}

@end

@implementation NSMutableSet (FSQFoundation)

- (id) popObject {
	id object = [self anyObject];
	if (object) {
		[self removeObject:object];
	}
	return object;
}

- (NSSet *) popObjects:(NSUInteger)count {
	NSMutableSet *objects = [NSMutableSet new];
	NSMutableArray *array = [[self allObjects] mutableCopy];
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (objects.count >= count) {
			*stop = YES;
			return;
		}
		[objects addObject:obj];
		[self removeObject:obj];
	}];
	return objects;
}

@end
