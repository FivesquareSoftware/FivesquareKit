//
//  FSQKeyValueMapper.m
//  FivesquareKit
//
//  Created by John Clayton on 5/22/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQBindingsMapper.h"

#import "NSObject+FSQFoundation.h"
#import "NSString+FSQFoundation.h"


@implementation FSQBindingsMapper


+ (id) mapperForClass:(Class)aClass {
	return [self withBindingsNamed:[aClass className]];
}

+ (id) withBindingsNamed:(NSString *)name {
	FSQBindingsMapper *mapper = nil;
	NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.bindings",name] ofType:@"plist"];
	if(NO == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
	}
	if(NO == [[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [[NSBundle mainBundle] pathForResource:name ofType:@"bindings"];
	}
	if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSArray *classBindings = [NSArray arrayWithContentsOfFile:path];
		if (nil == classBindings) {
			NSDictionary *bindingsDict = [NSDictionary dictionaryWithContentsOfFile:path];
			classBindings = [bindingsDict objectForKey:[[bindingsDict allKeys] lastObject]];
		}
		mapper = [[FSQBindingsMapper alloc] initWithBindings:classBindings];
	} 
	return mapper;
}

- (id) initWithBindings:(NSArray *)someBindings {
	self = [super init];
	if (self != nil) {
		_bindings = someBindings;
		_mergePolicy = FSQBindingsMapperMergePolicySourceObjectTrumpsDestination;
	}
	return self;
}

- (BOOL) mapSource:(id)source toTarget:(id)target error:(NSError **)error {
	for (NSDictionary *binding in self.bindings) {
		NSString *sourceKeyPath = [binding objectForKey:@"sourceKeyPath"];
		NSString *destinationKeyPath = [binding objectForKey:@"destinationKeyPath"];
		NSString *valueTransformerName = [binding objectForKey:@"valueTransformerName"];
		
		id value = [source valueForKeyPath:sourceKeyPath];
		
		// we want to check if the source object actually responded to this key or was simply missing it, missing values should not be mapped
		if (value == nil) {
			SEL sourceKeySelector = NSSelectorFromString(sourceKeyPath);
			BOOL hasKey = [source respondsToSelector:sourceKeySelector];
			if (NO == hasKey) {
				continue;
			}
		}

        if (value == [NSNull null]) {
            value = nil;
        }
		
		if (NO == [NSString isEmpty:valueTransformerName]) {
			NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];
			if (valueTransformer) {
				value = [valueTransformer transformedValue:value];
			}
		}
		if (_mergePolicy == FSQBindingsMapperMergePolicySourceObjectTrumpsDestination) {
			if (NO == [target setValue:value forKeyPath:destinationKeyPath error:error]) {
				return NO;
			}
		}
		else if (_mergePolicy == FSQBindingsMapperMergePolicyDestinationObjectTrumpsSource) {
			id destinationValue = [target valueForKeyPath:destinationKeyPath];
			
			BOOL destinationEmpty = [NSObject isEmpty:destinationValue];
			if (NO == destinationEmpty) {
				if ([destinationValue isKindOfClass:[NSString class]]) {
					destinationEmpty = [NSString isEmpty:destinationValue];
				}
				else if ([destinationValue isKindOfClass:[NSArray class]]) {
					destinationEmpty = [NSArray isEmpty:destinationValue];
				}
				else if ([destinationValue isKindOfClass:[NSDictionary class]]) {
					destinationEmpty = [NSDictionary isEmpty:destinationValue];
				}
				else if ([destinationValue isKindOfClass:[NSSet class]]) {
					destinationEmpty = [NSSet isEmpty:destinationValue];
				}
			}
			
			if (destinationEmpty) {
				if (NO == [target setValue:value forKeyPath:destinationKeyPath error:error]) {
					return NO;
				}
			}
		}
		
	}
	return YES;
}

@end
