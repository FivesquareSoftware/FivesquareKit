//
//  FSQObjectButton.m
//  FivesquareKit
//
//  Created by John Clayton on 4/8/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQObjectButton.h"

#import "NSObject+FSQFoundation.h"

@interface FSQObjectButton ()
@property (nonatomic, readonly) UIImage *placeholderImage;
@property (nonatomic, readonly) NSString *placeholderTitle;
@property (nonatomic, readonly) UIImage *representedImage;
@property (nonatomic, readonly) NSString *representedTitle;
@end

@implementation FSQObjectButton

- (void) setPlaceholderObject:(id)placeholderObject {
	if (_placeholderObject != placeholderObject) {
		_placeholderObject = placeholderObject;
		if (_representedObject == nil) {
			[self setImage:self.placeholderImage forState:UIControlStateNormal];
			[self setTitle:self.placeholderTitle forState:UIControlStateNormal];
		}
	}
}

- (void) setRepresentedObject:(id)representedObject {
	if (_representedObject != representedObject) {
		_representedObject = representedObject;
		if (_representedObject) {
			[self setImage:self.representedImage forState:UIControlStateNormal];
			[self setTitle:self.representedTitle forState:UIControlStateNormal];
		}
		else {
			[self setImage:self.placeholderImage forState:UIControlStateNormal];
			[self setTitle:self.placeholderTitle forState:UIControlStateNormal];
		}
	}
}

@dynamic placeholderImage;
- (UIImage *) placeholderImage {
	id value = [_placeholderObject valueForKeyPath:@"image" error:NULL];
	return value;
}

@dynamic placeholderTitle;
- (NSString *) placeholderTitle {
	id value = [_placeholderObject valueForKeyPath:@"title" error:NULL];
	return value;
}

@dynamic representedImage;
- (UIImage *) representedImage {
	id value = [_representedObject valueForKeyPath:@"image" error:NULL];
	return value;
}

@dynamic representedTitle;
- (NSString *) representedTitle {
	id value = [_representedObject valueForKeyPath:@"title" error:NULL];
	return value;
}

@end
	
