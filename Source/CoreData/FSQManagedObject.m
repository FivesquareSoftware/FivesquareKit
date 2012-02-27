//
//  FSQManagedObject.m
//  FivesquareKit
//
//  Created by John Clayton on 1/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQManagedObject.h"


@implementation FSQManagedObject

- (void) awakeFromInsert {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	NSDate *at = [NSDate date];
	if ([self respondsToSelector:@selector(setCreatedAt:)]) {
		[self setPrimitiveValue:at forKey:@"createdAt"];
	}
	if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
		[self setPrimitiveValue:at forKey:@"updatedAt"];
	}
#pragma clang diagnostic pop
}

- (void) willSave {
	if(NO == [self isDeleted]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
		if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
			[self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
		}
#pragma clang diagnostic pop
	}
}

@end
