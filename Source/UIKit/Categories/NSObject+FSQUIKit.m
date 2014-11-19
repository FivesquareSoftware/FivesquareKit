//
//  NSObject+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 11/16/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import "NSObject+FSQUIKit.h"

#import "NSObject+FSQFoundation.h"
#import "FSQAsserter.h"
#import "FSQLogging.h"

@implementation NSObject (FSQUIKit)

@dynamic appDelegate;

- (id) appDelegate {
    return (id)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)nibName {
	return [self className];
}

+ (id) withNibOwner:(id)owner {
	return [self withNibNamed:[self nibName] owner:owner];
}

+ (id) withNibNamed:(NSString *)nibName owner:(id)owner {
	id object = [self withNib:[UINib nibWithNibName:nibName bundle:nil] owner:owner];
	if (nil == object) {
		FLogWarn(@"Could not find object of class %@ in nib %@",[self class], nibName);
	}
	return object;
}

+ (id) withNib:(UINib *)nib owner:(id)owner {
	NSArray *objects = [nib instantiateWithOwner:owner options:nil];
	id object = nil;
	for (id obj in objects) {
		if ([obj isKindOfClass:self]) {
			object = obj;
			break;
		}
	}
	return object;
}


@end