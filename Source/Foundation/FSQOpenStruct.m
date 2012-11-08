//
//  FSQOpenStruct.m
//  FivesquareKit
//
//  Created by John Clayton on 2/5/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQOpenStruct.h"

#import "NSDictionary+FSQFoundation.h"

@implementation FSQOpenStruct

@synthesize attributes = _attributes;

- (NSMutableDictionary *) attributes {
	@synchronized(self) {
		if (nil == _attributes) {
			_attributes = [NSMutableDictionary new];
		}
	}
	return _attributes;
}

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        _attributes = [attributes mutableDeepCopy];
    }
    return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ : %@", [super description], [self.attributes description]];
}

// ========================================================================== //

#pragma mark - KVC


- (id)valueForKey:(NSString *)key {
	id value = [self.attributes valueForKey:key];
	if (nil == value) {
		value = [NSMutableDictionary new];
		[self.attributes setObject:value forKey:key];
	}
	return value;
}

- (void)setValue:(id)value forKey:(NSString *)key {
	[self willChangeValueForKey:key];
	if (nil == value) {
		value = [NSNull null];
	}
	[self.attributes setValue:value forKey:key];
	[self didChangeValueForKey:key];
}

- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys {
	return [self.attributes dictionaryWithValuesForKeys:keys];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
	for (NSString *key in keyedValues) {
		[self willChangeValueForKey:key];
	}
	[self.attributes setValuesForKeysWithDictionary:keyedValues];
	for (NSString *key in keyedValues) {
		[self didChangeValueForKey:key];
	}
}

// ========================================================================== //

#pragma mark - Proxy

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//	return [_attributes methodSignatureForSelector:aSelector];
//}
//
//- (void)forwardInvocation:(NSInvocation *)invocation {
//	[invocation invokeWithTarget:_attributes];
//}




@end
