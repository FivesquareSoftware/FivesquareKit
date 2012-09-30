//
//  NSObject+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 6/28/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "NSObject+FSQFoundation.h"

#import "FSQFoundationConstants.h"
#import "FSQPropertyMapper.h"
#import "NSError+FSQFoundation.h"

@implementation NSObject (FSQFoundation)

+ (BOOL) isEmpty:(id)obj {
	if (nil == obj) {
		return YES;
	}
	if ([NSNull null] == obj) {
		return YES;
	}	
	
	return NO;
}

+ (BOOL) isNotEmpty:(id)obj {
	return NO == [self isEmpty:obj];
}


#if (TARGET_OS_IPHONE)
+ (NSString *) className {
	return NSStringFromClass(self);
}

- (NSString *) className {
	return NSStringFromClass([self class]);
}
#endif

- (BOOL) setValue:(id)value forKeyPath:(NSString *)keyPath error:(NSError **)error {
	@try {
		[self setValue:value forKeyPath:keyPath];
	}
	@catch (NSException *exception) {
		NSDictionary *info = @{kFSQMapperErrorInfoKeyFailingDestinationKeyPath: keyPath
							  , @"Failed to map a keypath": NSLocalizedDescriptionKey
							  , exception: NSUnderlyingErrorKey};
		NSError *mappingError = [NSError errorWithDomain:kFSQFoundationErrorDomain code:kFSQMapperErrorCodeMappingFailed userInfo:info];
		if (error) {
			*error = mappingError;
		}
		return NO;
	}
	return YES;
}

- (id) valueForKeyPath:(NSString *)keyPath error:(NSError **)error {
	id value = nil;
	@try {
		value = [self valueForKeyPath:keyPath];
	}
	@catch (NSException *exception) {
		if (error) {
			*error = [NSError withException:exception];
		}
	}
	return value;
}

- (BOOL) mapFromObject:(NSObject *)source error:(NSError **)error {
	FSQPropertyMapper *mapper = [FSQPropertyMapper withTargetObject:self];
	return [mapper mapFromObject:source error:error];
}

@end
