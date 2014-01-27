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

@implementation NSObject (FSQUIKit)

@dynamic appDelegate;

- (id) appDelegate {
    return (id)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)nibName {
	return [self className];
}

+ (id) loadFromNib {
	return [self loadFromNibWithOwner:self];
}

+ (id) loadFromNibWithOwner:(id)owner {
	NSArray *theObjects = [[NSBundle mainBundle] loadNibNamed:[self nibName] owner:owner options:nil];
	for (id theObject in theObjects) {
		if ([theObject isKindOfClass:self])
			return(theObject);
	}
	NSString *warning = [NSString stringWithFormat:@"Could not find object of class %@ in nib %@", [self class], [self nibName]];
	FSQAssert(NO, warning);
	return nil;
}

+ (id) withNibOwner:(id)owner {
	return [self withNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] owner:owner];
}

+ (id) withNib:(UINib *)nib owner:(id)owner {
	NSArray *objects = [nib instantiateWithOwner:owner options:nil];
	id object = nil;
	Class myClass = [self class];
	for (id obj in objects) {
		if ([obj isKindOfClass:myClass]) {
			object = obj;
			break;
		}
	}
	return object;
}


@end