//
//  FSQLabel.m
//  FivesquareKit
//
//  Created by John Clayton on 7/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQLabel.h"

#import "NSString+FSQFoundation.h"


@interface FSQLabel ()
@property (nonatomic, strong) UIColor *textColorInternal;
@property (nonatomic, strong) NSLayoutConstraint *collapseConstraint;
@end

@implementation FSQLabel

- (void) setPlaceholderText:(NSString *)placeholderText {
	if (_placeholderText != placeholderText) {
		if (nil == placeholderText) {
			placeholderText = @"";
		}
		_placeholderText = placeholderText;
//		[super setTextColor:_placeholderColor];
//		[super setText:_placeholderText];
		if ([NSString isEmpty:self.text]) {
			[self applyPlaceholderText];
		}
	}
}

- (void) applyPlaceholderText {
	NSAttributedString *placeholderString = [[NSAttributedString alloc] initWithString:_placeholderText attributes:_placeholderAttributes];
	self.attributedText = placeholderString;
}

- (void) setText:(NSString *)text {
	if ([NSString isEmpty:text]) {
		if (_collapseWhenEmpty) {
			NSLayoutConstraint *collapseConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
			self.collapseConstraint = collapseConstraint;
		}
		else {
//			text = _placeholderText;
//			[super setTextColor:_placeholderColor];
			[self applyPlaceholderText];
			self.collapseConstraint = nil;
		}
	}
	else {
		self.collapseConstraint = nil;
		[super setText:text];
	}
	[self setNeedsLayout];
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
	self.translatesAutoresizingMaskIntoConstraints = NO;
	_placeholderAttributes = @{NSForegroundColorAttributeName : [UIColor lightTextColor], NSObliquenessAttributeName : @(.1)};
	_placeholderText = @"";
}

- (void) ready {
	
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
	[self ready];
}

@end
