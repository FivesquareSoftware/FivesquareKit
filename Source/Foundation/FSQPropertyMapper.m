//
//  FSQPropertyMapper.m
//  FivesquareKit
//
//  Created by John Clayton on 2/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQPropertyMapper.h"

#import <objc/runtime.h>
#import "NSObject+FSQFoundation.h"

@interface FSQPropertyMapper()
@property (nonatomic, strong) id object;
@end

@implementation FSQPropertyMapper

@synthesize object=object_;

+ (id) withTargetObject:(NSObject *)target {
	return [[self alloc] initWithTargetObject:target];
}

- (id) initWithTargetObject:(NSObject *)target {
    self = [super init];
    if (self) {
        self.object = target;
    }
    return self;
}

- (BOOL) mapFromObject:(NSObject *)source error:(NSError **)error {
	Class templateClass = [self.object class];
	
	unsigned int outCount;
	objc_property_t *properties = class_copyPropertyList(templateClass, &outCount);
	
	for (unsigned int i = 0; i < outCount; i++) {
		objc_property_t property = properties[i];		
		NSString *key = [NSString stringWithFormat:@"%s", property_getName(property)];		
		id value = [source valueForKey:key];		
		if (NO == [self.object setValue:value forKeyPath:key error:error]) {
			return NO;
		}
	}			
    free(properties);
	return YES;
}

@end
