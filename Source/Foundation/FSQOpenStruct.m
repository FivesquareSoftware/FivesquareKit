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


@synthesize attributes=attributes_;

- (NSMutableDictionary *) attributes {
	@synchronized(self) {
		if (nil == attributes_) {
			attributes_ = [NSMutableDictionary new];
		}
	}
	return attributes_;
}

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        attributes_ = [attributes mutableDeepCopy];
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




@end
