//
//  FSQManagedObject.m
//  FivesquareKit
//
//  Created by John Clayton on 1/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQManagedObject.h"


@implementation FSQManagedObject

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void) awakeFromInsert {
	NSDate *at = [NSDate date];
	if ([self respondsToSelector:@selector(setCreatedAt:)]) {
		[self setPrimitiveValue:at forKey:@"createdAt"];
	}
	if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
		[self setPrimitiveValue:at forKey:@"updatedAt"];
	}
}

- (void) willSave {
	if(NO == [self isDeleted]) {
		if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
			[self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
		}
	}
}

- (void) markForDeletion {
	if ([self respondsToSelector:@selector(setDeletedAt:)]) {
		[self setPrimitiveValue:[NSDate date] forKey:@"deletedAt"];
	}
}

#pragma clang diagnostic pop

@end
