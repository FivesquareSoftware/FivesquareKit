//
//  FSQKeyValueMapper.m
//  FivesquareKit
//
//  Created by John Clayton on 5/22/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeyValueMapper.h"

#import "NSObject+FSQFoundation.h"


@implementation FSQKeyValueMapper

@synthesize bindings=bindings_;


+ (id) mapperForClass:(Class)aClass {
	return [self withBindingsNamed:[aClass className]];
}

+ (id) withBindingsNamed:(NSString *)name {
	FSQKeyValueMapper *mapper = nil;
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"bindings"];
	if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSArray *classBindings = [NSArray arrayWithContentsOfFile:path];
		mapper = [[FSQKeyValueMapper alloc] initWithBindings:classBindings];
	} 
	return mapper;
}

- (id) initWithBindings:(NSArray *)someBindings {
	self = [super init];
	if (self != nil) {
		bindings_ = someBindings;
	}
	return self;
}

- (BOOL) mapSource:(id)source toTarget:(id)target error:(NSError **)error {
	for (NSDictionary *binding in self.bindings) {
		NSString *sourceKeyPath = [binding objectForKey:@"sourceKeyPath"];
		NSString *destinationKeyPath = [binding objectForKey:@"destinationKeyPath"];
		if (NO == [target setValue:[source valueForKeyPath:sourceKeyPath] forKeyPath:destinationKeyPath error:error]) {
			return NO;
		}
	}
	return YES;
}

@end
