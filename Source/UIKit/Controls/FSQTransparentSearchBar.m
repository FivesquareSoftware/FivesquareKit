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
	NSString *backgroundViewClassName = @"UISearchBarBackground";
	NSArray *subviews = [self subviews];
	if ([subviews count] == 1) {
		UIView *firstSubview = [subviews firstObject];
		NSString *firstViewClassName = NSStringFromClass([firstSubview class]);
		if (NO == [firstViewClassName isEqualToString:backgroundViewClassName]) {
			subviews = [firstSubview subviews];
			_usesContentView = YES;
		}
	}
	
	for (id subview in subviews) {
		NSString *subviewClassName = NSStringFromClass([subview class]);
		if ([subviewClassName isEqualToString:backgroundViewClassName]) {
			[subview removeFromSuperview];
			break;
		}
	}
	self.backgroundColor = [UIColor clearColor];
}

@end
