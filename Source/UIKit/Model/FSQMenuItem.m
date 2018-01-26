//
//  FSQMenuItem.m
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuItem.h"

#import "NSString+FSQFoundation.h"

@interface FSQMenuItem ()
@property (nonatomic, readwrite) NSString *displayName;

@end

@implementation FSQMenuItem



- (NSString *) displayName {
	id displayValue = _displayName;
	if (nil == displayValue) {
		displayValue = [self.representedObject valueForKeyPath:self.displayNameKeyPath];
	}
	if (nil == displayValue) {
		displayValue = self.representedObject;
	}
	return [displayValue description];
}

+ (id) withRepresentedObject:(id)representedObject {
	return [[self alloc] initWithRepresentedObject:representedObject];
}

+ (id) withRepresentedObject:(id)representedObject displayName:(NSString *)displayName {
	FSQMenuItem *item = [self withRepresentedObject:representedObject];
	item.displayName = displayName;
	return item;
}

- (id) initWithRepresentedObject:(id)representedObject {
    self = [super init];
    if (self) {
		self.representedObject = representedObject;
        _displayNameKeyPath = @"description";
    }
    return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ '%@'",[super description],self.displayName];
}

@end
