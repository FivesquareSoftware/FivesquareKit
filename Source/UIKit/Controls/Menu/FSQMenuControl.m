//
//  FSQMenuControl.m
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuControl.h"
#import "FSQMenuControl+Protected.h"

#import "FSQMenuItem.h"
#import "FSQMenuItemView.h"

#define kFSQMenuControlMenuItemHeight 44.f


@implementation FSQMenuControl 

// ========================================================================== //

#pragma mark - Properties


@dynamic backgroundImage;
- (void) setBackgroundImage:(UIImage *)backgroundImage {
	self.backgroundImageView.image = backgroundImage;
}

- (UIImage *) backgroundImage {
	return self.backgroundImageView.image;
}

- (void) setSelectionStyle:(FSQMenuSelectionStyle)selectionStyle {
	if (_selectionStyle != selectionStyle) {
		_selectionStyle = selectionStyle;
		[self setItemsSelectionStyle:selectionStyle];
	}
}

- (void) setItemAlignment:(NSTextAlignment)itemAlignment {
	if (_itemAlignment != itemAlignment) {
		_itemAlignment = itemAlignment;
		[self setItemsTextAlignment:itemAlignment];
	}
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex {
	[self setSelectedIndex:selectedIndex animated:NO];
}

@dynamic items;
- (NSArray *) items {
	return [self.itemsInternal copy];
}

@dynamic selectedItem;
- (FSQMenuItem *) selectedItem {
	if (self.selectedIndex >= self.itemsInternal.count) {
		return nil;
	}
	return [self.itemsInternal objectAtIndex:self.selectedIndex];
}

- (void) setSelectedItem:(FSQMenuItem *)selectedItem {
	[self setSelectedItem:selectedItem animated:NO];
}

@dynamic scrollEnabled;
- (void) setScrollEnabled:(BOOL)scrollEnabled {
	self.contentView.scrollEnabled = scrollEnabled;
}

- (BOOL) scrollEnabled {
	return self.contentView.scrollEnabled;
}

// Protected


- (NSMutableArray *) itemsInternal {
	if (_itemsInternal == nil) {
		_itemsInternal = [NSMutableArray new];
	}
	return _itemsInternal;
}

@synthesize backgroundImageView = _backgroundImageView;
- (UIImageView *) backgroundImageView {
	if (_backgroundImageView == nil) {
		UIImageView *newImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		newImageView.contentMode = UIViewContentModeScaleToFill;
		newImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[self insertSubview:newImageView atIndex:0];
		_backgroundImageView = newImageView;
	}
	return _backgroundImageView;
}

- (void) setBackgroundImageView:(UIImageView *)backgroundImageView {
	if (_backgroundImageView != backgroundImageView) {
		[_backgroundImageView removeFromSuperview];
		[self insertSubview:backgroundImageView atIndex:0];
		_backgroundImageView = backgroundImageView;
	}
}

@dynamic itemViews;
- (NSArray *) itemViews {
	return self.contentView.subviews;
}


// ========================================================================== //

#pragma mark - Object

- (void) initialize {
	// Common initialization
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self addGestureRecognizer:tapRecognizer];	
	_maxItemSize = CGSizeMake(self.bounds.size.width, kFSQMenuControlMenuItemHeight);
	_selectionStyle = FSQMenuSelectionStyleDefault;
	_itemAlignment = INT_MAX;
	_selectedIndex = UINT_MAX;
	
	UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
	contentView.showsHorizontalScrollIndicator = NO;
	contentView.showsVerticalScrollIndicator = NO;
	contentView.directionalLockEnabled = YES;
	contentView.scrollEnabled = NO;
	contentView.delegate = self;
	[self insertSubview:contentView atIndex:0];
	_contentView = contentView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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


// ========================================================================== //

#pragma mark - Menu Interface

- (void) addRepresentedObject:(id)representedObject {
	FSQMenuItem *menuItem = [FSQMenuItem withRepresentedObject:representedObject];
	menuItem.menu = self;
	if (self.displayNameKeyPath) {
		menuItem.displayNameKeyPath = self.displayNameKeyPath;
	}
	[self.itemsInternal addObject:menuItem];
	CGRect menuItemBounds = CGRectZero;
	menuItemBounds.size = _maxItemSize;

	FSQMenuItemView *menuView = [[FSQMenuItemView alloc] initWithFrame:menuItemBounds];
	menuView.menuItem = menuItem;
//	menuView.selectionStyle = self.selectionStyle;
//	menuView.textAlignment = self.itemAlignment;
	
	[self.contentView addSubview:menuView];
	
	[self setNeedsLayout];
}

- (void) addRepresentedObjects:(NSArray *)representedObjects {
	for (id object in representedObjects) {
		[self addRepresentedObject:object];
	}
}

- (void) setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
	if (_selectedIndex != selectedIndex) {
		FSQMenuItemView *currentView = _selectedIndex < self.itemViews.count ? [self.itemViews objectAtIndex:_selectedIndex] : nil;
		FSQMenuItemView *newView = [self.itemViews objectAtIndex:selectedIndex];

		_selectedIndex = selectedIndex;	

		NSTimeInterval duration = animated ? 0.265 : 0;
		[UIView animateWithDuration:duration animations:^{
			currentView.selected = NO;
			newView.selected = YES;
		}];
	}
}

- (FSQMenuItem *) itemAtIndex:(NSUInteger)index {
	if (index >= self.itemsInternal.count) {
		return nil;
	}
	return [self.itemsInternal objectAtIndex:index];
}


- (void) setSelectedItem:(FSQMenuItem *)selectedItem animated:(BOOL)animated {
	[self.itemsInternal enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (obj == selectedItem) {
			[self setSelectedIndex:idx animated:animated];
			*stop = YES;
		}
	}];
}


// ========================================================================== //

#pragma mark - UIControl

- (void) layoutSubviews {
	_contentView.frame = self.bounds;
	if (_direction == FSQMenuDirectionVertical) {
		CGFloat offsetY = 0;
		for (UIView *view in self.itemViews) {
			CGRect itemFrame = CGRectZero;
			itemFrame.origin = CGPointMake(0, offsetY);
			itemFrame.size = _maxItemSize;
			view.frame = itemFrame;
			offsetY += _maxItemSize.height;
		}
		if (offsetY > 0) {
			self.contentView.contentSize = CGSizeMake(self.bounds.size.width, offsetY);
		}

	} else if (_direction = FSQMenuDirectionHorizontal) {
		CGFloat offsetX = 0;	
		CGFloat deltaX = 0;
		CGFloat deltaY = 0;
		for (FSQMenuItemView *view in self.itemViews) {	
			CGSize fitSize = [view sizeThatFits:_maxItemSize];
			deltaX = (self.bounds.size.width - fitSize.width)/2;
			deltaY = (self.bounds.size.height - fitSize.height)/2;
			CGRect itemFrame = CGRectIntegral(CGRectInset(self.bounds, deltaX, deltaY));	
			if (offsetX > 0) {
				itemFrame.origin.x = offsetX;
			}
			view.frame = itemFrame;
			offsetX = (itemFrame.origin.x + itemFrame.size.width);
		}
		if (offsetX > 0) {
			self.contentView.contentSize = CGSizeMake(offsetX+deltaX, self.bounds.size.height);
		}
	}
}

// Gesture recognizer should handle this
//- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//	UIView *hitView = [super hitTest:point withEvent:event];
//	if (hitView == self || [self.subviews containsObject:hitView]) {
//		return self;
//	}
//	return hitView;
//}

- (void) handleTap:(UIGestureRecognizer *)recognizer {
	// test tap to see if/which menu item was tapped
	__block NSUInteger hitIndex = UINT_MAX;	
	[self.itemViews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		CGPoint location = [recognizer locationInView:subview];
		if (NO == CGPointEqualToPoint(CGPointZero, location)) {
			hitIndex = idx;
			*stop = YES;
		}
	}];
	if (hitIndex != UINT_MAX) {
		[self setSelectedIndex:hitIndex animated:YES];
	}	
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

// ========================================================================== //

#pragma mark - Helpers

- (void) setItemsSelectionStyle:(FSQMenuSelectionStyle)selectionStyle {
	[self.itemViews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		[(FSQMenuItemView *)subview setSelectionStyle:selectionStyle];
	}];
}

- (void) setItemsTextAlignment:(NSTextAlignment)textAlignment {
	[self.itemViews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		[(FSQMenuItemView *)subview setTextAlignment:textAlignment];
	}];
}



@end
