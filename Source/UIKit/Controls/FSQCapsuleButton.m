//
//  FSQCapsuleButton.m
//  FivesquareKit
//
//  Created by John Clayton on 8/6/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQCapsuleButton.h"

#import <QuartzCore/QuartzCore.h>

@interface FSQCapsuleButton ()
@property (nonatomic, weak) CALayer *capsuleLayer;
@end

@implementation FSQCapsuleButton

// ========================================================================== //

#pragma mark - Properties



- (void) setFillColor:(UIColor *)fillColor {
	if (_fillColor != fillColor) {
		_fillColor = fillColor;
		_capsuleLayer.backgroundColor = _fillColor.CGColor;
		[self setNeedsDisplay];
	}
}

- (void) setHighlightedFillColor:(UIColor *)highlightedFillColor {
	if (_highlightedFillColor != highlightedFillColor) {
		_highlightedFillColor = highlightedFillColor;
		[self setNeedsDisplay];
	}
}

- (void) setBorderColor:(UIColor *)borderColor {
	if (_borderColor != borderColor) {
		_borderColor = borderColor;
		_capsuleLayer.borderColor = _borderColor.CGColor;
		[self setNeedsDisplay];
	}
}

- (void) setHighlightedBorderColor:(UIColor *)highlightedBorderColor {
	if (_highlightedBorderColor != highlightedBorderColor) {
		_highlightedBorderColor = highlightedBorderColor;
		[self setNeedsDisplay];
	}
}

- (void) setBorderWidth:(CGFloat)borderWidth {
	if (_borderWidth != borderWidth) {
		_borderWidth = borderWidth;
		_capsuleLayer.borderWidth = _borderWidth;
		[self setNeedsDisplay];
	}
}

// ========================================================================== //

#pragma mark - Object



- (void) initialize {
#ifdef __IPHONE_6_0
	self.translatesAutoresizingMaskIntoConstraints = NO;
#endif
	
	_fillColor = [UIColor colorWithWhite:.75 alpha:1.f];
	CGFloat components[4];
	[_fillColor getHue:&components[0] saturation:&components[1] brightness:&components[2] alpha:&components[3]];
	_highlightedFillColor = [UIColor colorWithHue:components[0] saturation:components[1] brightness:components[2]-10.f alpha:components[3]];

	_borderColor = [UIColor whiteColor];
	_highlightedBorderColor = _borderColor;
//	[_borderColor getHue:&components[0] saturation:&components[1] brightness:&components[2] alpha:&components[3]];
//	_highlightedFillColor = [UIColor colorWithHue:components[0] saturation:components[1] brightness:components[2]-10.f alpha:components[3]];
	
	_borderWidth = 2.f;
}

- (void) ready {
	CALayer *capsuleLayer = [[CALayer alloc] init];
	capsuleLayer.backgroundColor = _fillColor.CGColor;
	capsuleLayer.borderColor = _borderColor.CGColor;
	capsuleLayer.borderWidth = _borderWidth;

	[self.layer insertSublayer:capsuleLayer below:self.imageView.layer];
	_capsuleLayer = capsuleLayer;		
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

// ========================================================================== //

#pragma mark - View



- (void) layoutSubviews {
	[super layoutSubviews];
	
	_capsuleLayer.cornerRadius = (self.bounds.size.height/2.f);
	_capsuleLayer.frame = self.bounds;	
}

- (void) setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	
	[UIView animateWithDuration:[CATransaction animationDuration] animations:^{
		if (highlighted) {
			_capsuleLayer.backgroundColor = _highlightedFillColor.CGColor;
			_capsuleLayer.borderColor = _highlightedBorderColor.CGColor;
		}
		else {
			_capsuleLayer.backgroundColor = _fillColor.CGColor;
			_capsuleLayer.borderColor = _borderColor.CGColor;
		}
	}];	
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
