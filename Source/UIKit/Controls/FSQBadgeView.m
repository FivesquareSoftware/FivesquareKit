//
//  FSQBadgeView.m
//  FivesquareKit
//
//  Created by John Clayton on 6/20/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQBadgeView.h"
#import "FSQGradientView.h"
#import "CALayer+FSQQuartz.h"

#define kFSQBadgeDimension 20.f
#define kFSQBadgeBorderWidth 2.f
#define kFSQBadgeEdgePadding 3.f


@interface FSQBadgeView ()
@property (nonatomic, weak) UILabel *badgeLabel;
@property (nonatomic, weak) UIView *backgroundView;
//@property (nonatomic, strong) NSArray *layoutConstraints;
@property (nonatomic) CGFloat intrinsicWidth;
@property (nonatomic, strong) NSDictionary *titleTextAttributes;
@end


@implementation FSQBadgeView

- (void) setBadgeColor:(UIColor *)badgeColor {
	if (_badgeColor != badgeColor) {
		_badgeColor = badgeColor;
		
		UIView *backgroundView = [self newBackgroundView];
		[_backgroundView removeFromSuperview];
		[self insertSubview:backgroundView atIndex:0];
		_backgroundView = backgroundView;
		[self setNeedsDisplay];
	}
}

- (void) setBadgeGradient:(NSArray *)badgeGradient {
	if (_badgeGradient != badgeGradient) {
		_badgeGradient = badgeGradient;

		UIView *backgroundView = [self newBackgroundView];
		[_backgroundView removeFromSuperview];
		[self insertSubview:backgroundView atIndex:0];
		_backgroundView = backgroundView;
		[self setNeedsDisplay];
	}
}

- (void) setBorderColor:(UIColor *)borderColor {
	if (_borderColor != borderColor) {
		_borderColor = borderColor;
		self.layer.borderColor = _borderColor.CGColor;
		[self.layer setShadowColor:_borderColor.CGColor opacity:.25 offset:CGSizeZero radius:2.f];
		[self setNeedsDisplay];
	}
}

- (void) setTitleTextAttributes:(NSDictionary *)attributes {
	if (NO == [_titleTextAttributes isEqualToDictionary:attributes]) {
		NSShadow *shadow = _titleTextAttributes[NSShadowAttributeName];
		
		_titleTextAttributes = attributes;
		_badgeLabel.font = _titleTextAttributes[NSFontAttributeName];
		_badgeLabel.textColor = _titleTextAttributes[NSForegroundColorAttributeName];
		_badgeLabel.shadowColor = shadow.shadowColor;
		_badgeLabel.shadowOffset = shadow.shadowOffset;
		[self setNeedsUpdateConstraints];
	}
}

@dynamic numberValue;
- (void) setNumberValue:(NSNumber *)numberValue {
	self.stringValue = [numberValue stringValue];
}

- (NSNumber *) numberValue {
	return @([self.stringValue integerValue]);
}

- (void) setStringValue:(NSString *)stringValue {
	if (_stringValue != stringValue) {
		_stringValue = stringValue;
		_badgeLabel.text = _stringValue;
//		[self invalidateIntrinsicContentSize];
		[self sizeToFit];
	}
}

/*
- (void) setLayoutConstraints:(NSArray *)layoutConstraints {
	if (_layoutConstraints != layoutConstraints) {
		if (_layoutConstraints) {
			[self removeConstraints:_layoutConstraints];
		}
		_layoutConstraints = layoutConstraints;
		if (_layoutConstraints) {
			[self addConstraints:_layoutConstraints];
		}
	}
}
 */

- (CGSize) intrinsicContentSize {
	CGSize labelFitSize = [_badgeLabel.text sizeWithFont:_badgeLabel.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, _badgeLabel.bounds.size.height) lineBreakMode:_badgeLabel.lineBreakMode];
	if (labelFitSize.width > _intrinsicWidth) {
		_intrinsicWidth = labelFitSize.width;
	}
//	CGSize intrinsicContentSize = CGSizeMake(_intrinsicWidth+(kFSQBadgeEdgePadding*2.f)+(kFSQBadgeBorderWidth*2.f), kFSQBadgeDimension);
	CGSize intrinsicContentSize = CGSizeMake(kFSQBadgeDimension, kFSQBadgeDimension);
	return intrinsicContentSize;
}

- (CGSize) sizeThatFits:(CGSize)size {
	return [self intrinsicContentSize];
}


// ========================================================================== //

#pragma mark - Object



- (void) initialize {
//	self.translatesAutoresizingMaskIntoConstraints = NO;
	_badgeGradient = @[
		[FSQGradientComponent withColor:[UIColor colorWithRed:.96 green:.74 blue:.75 alpha:1.] location:@(0)],
		[FSQGradientComponent withColor:[UIColor colorWithRed:.89 green:.25 blue:.30 alpha:1.] location:@(.40)],
		[FSQGradientComponent withColor:[UIColor colorWithRed:.86 green:.02 blue:.11 alpha:1.] location:@(.41)],
		[FSQGradientComponent withColor:[UIColor colorWithRed:.71 green:.0 blue:.04 alpha:1.] location:@(1.)]
	 ];
	_badgeColor = nil;
	_borderColor = [UIColor whiteColor];
	_titleTextAttributes = @{ UITextAttributeFont : [UIFont boldSystemFontOfSize:12.f],  UITextAttributeTextColor : [UIColor whiteColor], UITextAttributeTextShadowColor : [UIColor colorWithWhite:1. alpha:.35], UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(1, 0)]  };
	
	//	self.layer.backgroundColor = [SpotAppAppearance controlTintColor].CGColor;
	self.backgroundColor = [UIColor clearColor];
	self.userInteractionEnabled = NO;
}

- (void) ready {
	_intrinsicWidth = kFSQBadgeDimension;
	
	UIView *backgroundView = [self newBackgroundView];
	[self addSubview:backgroundView];
	_backgroundView = backgroundView;
	
	self.layer.borderColor = _borderColor.CGColor;
	self.layer.borderWidth = kFSQBadgeBorderWidth;
	[self.layer setShadowColor:[UIColor blackColor].CGColor opacity:.45 offset:CGSizeMake(0, 1.) radius:3.f];
	
	
	UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	badgeLabel.backgroundColor = [UIColor clearColor];
	badgeLabel.font = _titleTextAttributes[UITextAttributeFont];
	badgeLabel.textColor = _titleTextAttributes[UITextAttributeTextColor];
//	NSShadow *shadow = _titleTextAttributes[NSShadowAttributeName];
//	badgeLabel.shadowColor = shadow.shadowColor;
//	badgeLabel.shadowOffset = shadow.shadowOffset;
	badgeLabel.shadowColor = _titleTextAttributes[UITextAttributeTextShadowColor];
	badgeLabel.shadowOffset = [_titleTextAttributes[UITextAttributeTextShadowOffset] CGSizeValue];
	badgeLabel.adjustsFontSizeToFitWidth = NO;
	badgeLabel.adjustsLetterSpacingToFitWidth = NO;
	badgeLabel.textAlignment = NSTextAlignmentCenter;
	badgeLabel.text = @"0";
	[badgeLabel sizeToFit];
	[self addSubview:badgeLabel];
	_badgeLabel = badgeLabel;
	
	[self sizeToFit];
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

/*
- (void) updateConstraints {
	[super updateConstraints];
	
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_backgroundView,_badgeLabel);
	NSDictionary *metrics = @{ @"borderWidth" : @(kFSQBadgeBorderWidth) };
	
	NSMutableArray *layoutConstraints = [NSMutableArray new];
	
	[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-borderWidth-[_backgroundView]-borderWidth-|" options:0 metrics:metrics views:viewsDictionary]];
	[layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-borderWidth-[_backgroundView]-borderWidth-|" options:0 metrics:metrics views:viewsDictionary]];
	[layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_badgeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1. constant:0]];
	[layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_badgeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1. constant:1.]];
	
	self.layoutConstraints = layoutConstraints;
}
 */

- (void) layoutSubviews {
	[super layoutSubviews];
	
	self.layer.cornerRadius = self.bounds.size.height/2.f;
	
	_badgeLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	
	CGRect backgroundFrame = CGRectInset(self.bounds, kFSQBadgeBorderWidth, kFSQBadgeBorderWidth);
	_backgroundView.frame = backgroundFrame;
	_backgroundView.layer.cornerRadius = backgroundFrame.size.height/2.f;
}




// ========================================================================== //

#pragma mark - Helpers


- (UIView *) newBackgroundView {
	UIView *backgroundView;
	if (_badgeGradient) {
		FSQGradientView *gradientBackgroundView = [[FSQGradientView alloc] initWithFrame:self.bounds];
		[gradientBackgroundView setGradientComponents:_badgeGradient];
		[gradientBackgroundView setType:kFSQGradientViewRadial];
		[gradientBackgroundView setStartPoint:CGPointMake(.5, 0)];
		backgroundView = gradientBackgroundView;
	}
	else {
		backgroundView = [[UIView alloc] initWithFrame:self.bounds];
		backgroundView.backgroundColor = self.badgeColor;
		backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
	}
	backgroundView.clipsToBounds = YES;

	CGRect backgroundFrame = CGRectInset(self.bounds, kFSQBadgeBorderWidth, kFSQBadgeBorderWidth);
	backgroundView.layer.cornerRadius = backgroundFrame.size.height/2.f;

	
	return backgroundView;
}



@end
