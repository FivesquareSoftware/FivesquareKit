//
//  FSQMenuItem.m
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuItem.h"

@implementation FSQMenuItem

@synthesize representedObject=representedObject_;
@synthesize displayNameKeyPath=displayNameKeyPath_;
@synthesize menu=menu_;

@dynamic displayName;
- (NSString *) displayName {
	id displayValue = [self.representedObject valueForKeyPath:self.displayNameKeyPath];
	if (displayValue == nil) {
		displayValue = self.representedObject;
	}
	return [displayValue description];
}

+ (id) withRepresentedObject:(id)representedObject {
	return [[self alloc] initWithRepresentedObject:representedObject];
}

- (id) initWithRepresentedObject:(id)representedObject {
    self = [super init];
    if (self) {
		self.representedObject = representedObject;
        displayNameKeyPath_ = @"description";
    }
    return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ '%@'",[super description],self.displayName];
}

@end
