//
//  FSQLabel.m
//  FivesquareKit
//
//  Created by John Clayton on 7/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQLabel.h"

#import "NSString+FSQFoundation.h"


#ifdef __IPHONE_6_0

@interface FSQLabel ()
@property (nonatomic, strong) UIColor *textColorInternal;
@property (nonatomic, strong) NSLayoutConstraint *collapseConstraint;
@end

@implementation FSQLabel

- (void) setPlaceholderText:(NSString *)placeholderText {
	if (_placeholderText != placeholderText) {
		_placeholderText = placeholderText;
		[super setTextColor:_placeholderColor];
		[super setText:_placeholderText];
	}
}

- (void) setText:(NSString *)text {
	if ([NSString isEmpty:text]) {
		if (_collapseWhenEmpty) {
			NSLayoutConstraint *collapseConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
			self.collapseConstraint = collapseConstraint;
			[self setNeedsLayout];
		}
		else {
			text = _placeholderText;
			[super setTextColor:_placeholderColor];
			if (_collapseWhenEmpty) {
				self.collapseConstraint = nil;
				[self setNeedsLayout];
			}
		}
	}
	else {
		[super setTextColor:_textColorInternal];
	}
	[super setText:text];
}

- (void) setTextColor:(UIColor *)textColor {
	[super setTextColor:textColor];
	_textColorInternal = textColor;
}


- (void) setCollapseConstraint:(NSLayoutConstraint *)collapseConstraint {
	if (_collapseConstraint != collapseConstraint) {
		if (_collapseConstraint) {
			[self removeConstraint:_collapseConstraint];
		}
		_collapseConstraint = collapseConstraint;
		if (_collapseConstraint) {
			[self addConstraint:_collapseConstraint];
		}
	}
}


- (void) initialize {
#ifdef __IPHONE_6_0
	self.translatesAutoresizingMaskIntoConstraints = NO;
#endif
	_placeholderColor = [UIColor lightTextColor];
	[self setTextColor:_placeholderColor];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
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



@end

#endif
