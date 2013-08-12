//
//  FSQTransparentSearchBar.m
//  FivesquareKit
//
//  Created by John Clayton on 4/6/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTransparentSearchBar.h"


@implementation FSQTransparentSearchBar

- (void) initialize {
//	self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void) ready {
	[self removeBackground];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
		[self ready];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self ready];
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
