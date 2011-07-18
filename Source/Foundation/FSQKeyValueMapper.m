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

@synthesize bindings;


+ (FSQKeyValueMapper *) mapperForClass:(Class)aClass {
	FSQKeyValueMapper *mapper = nil;
	NSString *path = [[NSBundle mainBundle] pathForResource:[aClass className] ofType:@"bindings"];
	if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSArray *classBindings = [NSArray arrayWithContentsOfFile:path];
		mapper = [[FSQKeyValueMapper alloc] initWithBindings:classBindings];
	} 
	return mapper;
}

- (id) initWithBindings:(NSArray *)someBindings {
	self = [super init];
	if (self != nil) {
		bindings = someBindings;
	}
	return self;
}

- (void) mapSource:(id)source toTarget:(id)target {
	for (NSDictionary *binding in self.bindings) {
		NSString *bind = [binding objectForKey:@"bind"];
		NSString *keyPath = [binding objectForKey:@"keyPath"];
		[target setValue:[source valueForKey:keyPath] forKey:bind];
	}
}

@end
