//
//  FSQManagedObject.m
//  FivesquareKit
//
//  Created by John Clayton on 1/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQManagedObject.h"

#import "NSString+FSQFoundation.h"

NSString *kFSQManagedObjectCreatedAtKey			= @"createdAt";
NSString *kFSQManagedObjectUpdatedAtKey			= @"updatedAt";
NSString *kFSQManagedObjectDeletedAtKey			= @"deletedAt";
NSString *kFSQManagedObjectUniqueIdentifierKey	= @"uniqueIdentifier";


@implementation FSQManagedObject


@dynamic allAttributes;
- (NSDictionary *) allAttributes {
	NSArray *keys = [[[self entity] attributesByName] allKeys];
	NSDictionary *allAttributes = [self dictionaryWithValuesForKeys:keys];
	return allAttributes;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void) markForDeletion {
	if ([self respondsToSelector:@selector(setDeletedAt:)]) {
		[self setPrimitiveValue:[NSDate date] forKey:kFSQManagedObjectDeletedAtKey];
	}
}

- (void) awakeFromInsert {
	NSDate *at = [NSDate date];
	if ([self respondsToSelector:@selector(setCreatedAt:)]) {
		[self setPrimitiveValue:at forKey:kFSQManagedObjectCreatedAtKey];
	}
	if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
		[self setPrimitiveValue:at forKey:kFSQManagedObjectUpdatedAtKey];
	}
	if ([self respondsToSelector:@selector(setUniqueIdentifier:)]) {
		NSUUID *UUID = [NSUUID new];
		[self setPrimitiveValue:[UUID UUIDString] forKey:kFSQManagedObjectUniqueIdentifierKey];
	}

}

- (void) willSave {
	if(NO == [self isDeleted]) {
		if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
			[self setPrimitiveValue:[NSDate date] forKey:kFSQManagedObjectUpdatedAtKey];
		}
		if ([self respondsToSelector:@selector(setUniqueIdentifier:)]) {
			NSString *uniqueIdentifier = [self primitiveValueForKey:kFSQManagedObjectUniqueIdentifierKey];
			if ([NSString isEmpty:uniqueIdentifier]) {
				NSUUID *UUID = [NSUUID new];
				[self setPrimitiveValue:[UUID UUIDString] forKey:kFSQManagedObjectUniqueIdentifierKey];
			}
		}
	}
}

#pragma clang diagnostic pop

@end
