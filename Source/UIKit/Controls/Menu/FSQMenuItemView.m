//
//  FSQMenuItemView.m
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuItemView.h"

#import "FSQMenuItem.h"
#import "FSQMenuControl.h"


#define FSQMenuItemViewPadding 3.f


@interface FSQMenuItemView ()
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, strong, readonly) UIView *defaultSelectionStyleBackgroundView;
@end

@implementation FSQMenuItemView

// ========================================================================== //

#pragma mark - Properties



- (void) setEdgeInsets:(UIEdgeInsets)edgeInsets {
	if (NO == UIEdgeInsetsEqualToEdgeInsets(_edgeInsets, edgeInsets)) {
		_edgeInsets = edgeInsets;
		[(FSQMenuControl *)self.menuItem.menu setNeedsLayout];
	}
}

- (void) setSelected:(BOOL)selected {
	if (_selected != selected) {
		self.textLabel.highlighted = selected;
		self.backgroundView.hidden = selected;
		self.selectedBackgroundView.hidden = !selected;
		_selected = selected;
	}
}

@dynamic textAlignment;
- (void) setTextAlignment:(NSTextAlignment)textAlignment {
	self.textLabel.textAlignment = textAlignment;
}

- (NSTextAlignment) textAlignment {
	return self.textLabel.textAlignment;
}

@dynamic font;
- (void) setFont:(UIFont *)font {
	self.textLabel.font = font;
	[(FSQMenuControl *)self.menuItem.menu setNeedsLayout];
}

- (UIFont *) font {
	return self.textLabel.font;
}

- (void) setSelectionStyle:(FSQMenuSelectionStyle)selectionStyle {
	if (_selectionStyle != selectionStyle) {
		_selectionStyle = selectionStyle;
		switch (selectionStyle) {
			case FSQMenuSelectionStyleNone:
				self.selectedBackgroundView = nil;
				self.textColor = [UIColor darkTextColor];
				self.selectedTextColor = self.textColor;
				break;
			case FSQMenuSelectionStyleDefault:
				self.selectedBackgroundView = self.defaultSelectionStyleBackgroundView;
				self.textColor = [UIColor darkTextColor];
				self.selectedTextColor = [UIColor lightTextColor];
				break;
				
			default:
				break;
		}
	}
}

- (void) setBackgroundView:(UIView *)backgroundView {
	if (_backgroundView != backgroundView) {
		[_backgroundView removeFromSuperview];
		if (backgroundView) {
			if (self.selectedBackgroundView) {
				[self insertSubview:backgroundView belowSubview:self.selectedBackgroundView];
			} else {
				[self insertSubview:backgroundView atIndex:0];
			}
		}
		_backgroundView = backgroundView;
	}
}

- (void) setSelectedBackgroundView:(UIView *)selectedBackgroundView {
	if (_selectedBackgroundView != selectedBackgroundView) {
		[_selectedBackgroundView removeFromSuperview];
		if (selectedBackgroundView) {
			selectedBackgroundView.hidden = !self.selected;
			if (self.backgroundView) {
				[self insertSubview:selectedBackgroundView aboveSubview:self.backgroundView];
			} else {
				[self insertSubview:selectedBackgroundView atIndex:0];
			}
		}
		_selectedBackgroundView = selectedBackgroundView;
	}
}

@dynamic textColor;
- (UIColor *) textColor {
	return self.textLabel.textColor;
}

- (void) setTextColor:(UIColor *)textColor {
	self.textLabel.textColor = textColor;
}

@dynamic selectedTextColor;
- (UIColor *) selectedTextColor {
	return self.textLabel.highlightedTextColor;
}

- (void) setSelectedTextColor:(UIColor *)selectedTextColor {
	self.textLabel.highlightedTextColor = selectedTextColor;
}



// Private


- (void) setMenuItem:(FSQMenuItem *)menuItem {
	if (_menuItem != menuItem) {
		_menuItem = menuItem;
		self.textLabel.text = menuItem.displayName;
	}
}

@synthesize defaultSelectionStyleBackgroundView = _defaultSelectionStyleBackgroundView;
- (UIView *) defaultSelectionStyleBackgroundView {
	if (_defaultSelectionStyleBackgroundView == nil) {
		_defaultSelectionStyleBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
		//TODO: make this a view that draws a nice gradient rather than just this solid color
		_defaultSelectionStyleBackgroundView.backgroundColor = [UIColor blueColor];
	}
	return _defaultSelectionStyleBackgroundView;
}


// ========================================================================== //

#pragma mark - UIView



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
						
		UILabel *newLabel = [[UILabel alloc] initWithFrame:self.bounds];
		newLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		newLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		newLabel.backgroundColor = [UIColor clearColor];
		newLabel.font = [UIFont boldSystemFontOfSize:17];
		newLabel.textColor = [UIColor darkTextColor];
		newLabel.highlightedTextColor = [UIColor lightTextColor];
		[self addSubview:newLabel];
		_textLabel = newLabel;
		
		_edgeInsets = UIEdgeInsetsZero;
		
		UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
		[self insertSubview:backgroundView atIndex:0];
		_backgroundView = backgroundView;
		
		[self insertSubview:self.defaultSelectionStyleBackgroundView aboveSubview:_backgroundView];
		_selectedBackgroundView = self.defaultSelectionStyleBackgroundView;
		
		_selectionStyle = FSQMenuSelectionStyleDefault;
    }
    return self;
}


- (CGSize) sizeThatFits:(CGSize)size {
	
	CGFloat horizontalInsets = _edgeInsets.left + _edgeInsets.top;
	CGFloat verticalInsets = _edgeInsets.top + _edgeInsets.bottom;
	CGSize fitSize = size;
//	CGSize labelSize = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:size lineBreakMode:self.textLabel.lineBreakMode];

	CGRect boundingRect = [self.textLabel.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : self.textLabel.font} context:[NSStringDrawingContext new]];
	CGSize labelSize = boundingRect.size;
	if ((labelSize.width + horizontalInsets) < fitSize.width) {
		fitSize.width = (labelSize.width + horizontalInsets);
	}
	if ((labelSize.height + verticalInsets) < fitSize.height) {
		fitSize.height = labelSize.height;
	}
	return fitSize;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	CGRect labelFrame = self.textLabel.frame;
	CGFloat deltaY = self.bounds.size.height - labelFrame.size.height;
	CGRect centeredFrame = CGRectIntegral(CGRectInset(self.bounds, 0, deltaY/2));
	self.textLabel.frame = centeredFrame;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}


@end
