//
//  FSQTransparentSearchBar.m
//  FivesquareKit
//
//  Created by John Clayton on 4/6/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTransparentSearchBar.h"

@interface FSQTransparentSearchBar ()
- (void) removeBackground;
@end


@implementation FSQTransparentSearchBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
		[self removeBackground];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self removeBackground];
	}
	return self;
}

- (void) removeBackground {
	for (id subview in [self subviews]) {
		NSString *subviewClassName = NSStringFromClass([subview class]);
		if ([subviewClassName isEqualToString:@"UISearchBarBackground"]) {
			[subview removeFromSuperview];
			break;
		}
	}
	self.backgroundColor = [UIColor clearColor];
}

@end
