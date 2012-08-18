//
//  FSQCapsuleButton.m
//  FivesquareKit
//
//  Created by John Clayton on 8/6/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQCapsuleButton.h"

#import <QuartzCore/QuartzCore.h>
#import "UIColor+FSQUIKit.h"

#define kFSQCapsuleButtonFillColorAdjustment -.1
#define kFSQCapsuleButtonEdgeWidth .5


@interface FSQCapsuleButton ()
@property (nonatomic, weak) CALayer *capsuleLayer;
//@property (nonatomic, weak) CALayer *edgeLayer;
@end

@implementation FSQCapsuleButton

// ========================================================================== //

#pragma mark - Properties


- (void) setFillColor:(UIColor *)fillColor {
	if (_fillColor != fillColor) {
		_fillColor = fillColor;
		if (nil == _fillColor) {
			_fillColor = [UIColor clearColor];
		}
		_capsuleLayer.backgroundColor = _fillColor.CGColor;
		[self setNeedsDisplay];
	}
}

@synthesize highlightedFillColor = _highlightedFillColor;
- (UIColor *) highlightedFillColor {
	if (nil == _highlightedFillColor) {
		return [_fillColor colorWithBrightnessAdjustment:kFSQCapsuleButtonFillColorAdjustment];
	}
	return _highlightedFillColor;
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
		if (nil == _borderColor) {
			_borderColor = [UIColor clearColor];
		}
		_capsuleLayer.borderColor = _borderColor.CGColor;
		[self setNeedsDisplay];
	}
}

@synthesize highlightedBorderColor = _highlightedBorderColor;
- (UIColor *) highlightedBorderColor {
	if (nil == _highlightedBorderColor) {
		return _borderColor;
	}
	return _highlightedBorderColor;
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
		[self setNeedsLayout];
	}
}

- (void) setEdgeColor:(UIColor *)edgeColor {
	if (_edgeColor != edgeColor) {
		_edgeColor = edgeColor;
		if (nil == _edgeColor) {
			_edgeColor = [UIColor clearColor];
		}
		self.layer.shadowColor = _edgeColor.CGColor;
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
	_borderColor = [UIColor whiteColor];
	_edgeColor = [UIColor clearColor];

	_borderWidth = 2.f;
}

- (void) ready {
	CALayer *capsuleLayer = [[CALayer alloc] init];
	capsuleLayer.backgroundColor = _fillColor.CGColor;
	capsuleLayer.borderColor = _borderColor.CGColor;
	capsuleLayer.borderWidth = _borderWidth;
	capsuleLayer.needsDisplayOnBoundsChange = YES;
	
	[self.layer insertSublayer:capsuleLayer below:self.imageView.layer];
	_capsuleLayer = capsuleLayer;

	
	CALayer *layer = self.layer;
	layer.shadowColor = _edgeColor.CGColor;
	layer.shadowOpacity = 1.f;
	layer.shadowOffset = CGSizeZero;
	layer.shadowRadius = kFSQCapsuleButtonEdgeWidth;
	
//	CALayer *edgeLayer = [[CALayer alloc] init];
//	edgeLayer.backgroundColor = _edgeColor.CGColor;
//	[self.layer insertSublayer:edgeLayer below:_capsuleLayer];
//	_edgeLayer = edgeLayer;
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
	
//	_edgeLayer.frame = self.bounds;
//	_edgeLayer.cornerRadius = (self.bounds.size.height/2.f);
//	
//	CGRect capsuleFrame = CGRectInset(self.bounds, kFSQCapsuleButtonEdgeWidth, kFSQCapsuleButtonEdgeWidth);
//	
//	_capsuleLayer.cornerRadius = (capsuleFrame.size.height/2.f);
//	_capsuleLayer.frame = capsuleFrame;
	
	CGRect bounds = self.bounds;
	_capsuleLayer.frame = bounds;
	CGFloat cornerDimension = (bounds.size.height > bounds.size.width ? bounds.size.width : bounds.size.height);
	_capsuleLayer.cornerRadius = (cornerDimension/2.f);
}

- (void) setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	
	[UIView animateWithDuration:[CATransaction animationDuration] animations:^{
		if (highlighted) {
			_capsuleLayer.backgroundColor = self.highlightedFillColor.CGColor;
			_capsuleLayer.borderColor = self.highlightedBorderColor.CGColor;
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
