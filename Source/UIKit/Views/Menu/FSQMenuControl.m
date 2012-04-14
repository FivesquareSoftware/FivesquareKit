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

@synthesize displayNameKeyPath=displayNameKeyPath_;
@synthesize maxItemSize=maxItemSize_;
@synthesize selectionStyle=selectionStyle_;
@synthesize itemAlignment=itemAlignment_;
@synthesize direction=direction_;
@synthesize selectedIndex=selectedIndex_;

@dynamic backgroundImage;
- (void) setBackgroundImage:(UIImage *)backgroundImage {
	self.backgroundImageView.image = backgroundImage;
}

- (UIImage *) backgroundImage {
	return self.backgroundImageView.image;
}

- (void) setSelectionStyle:(FSQMenuSelectionStyle)selectionStyle {
	if (selectionStyle_ != selectionStyle) {
		selectionStyle_ = selectionStyle;
		[self setItemsSelectionStyle:selectionStyle];
	}
}

- (void) setItemAlignment:(UITextAlignment)itemAlignment {
	if (itemAlignment_ != itemAlignment) {
		itemAlignment_ = itemAlignment;
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

@synthesize itemsInternal=itemsInternal_;
@synthesize backgroundImageView=backgroundImageView_;
@synthesize contentView=contentView_;

- (NSMutableArray *) itemsInternal {
	if (itemsInternal_ == nil) {
		itemsInternal_ = [NSMutableArray new];
	}
	return itemsInternal_;
}

- (UIImageView *) backgroundImageView {
	if (backgroundImageView_ == nil) {
		UIImageView *newImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		newImageView.contentMode = UIViewContentModeScaleToFill;
		newImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[self insertSubview:newImageView atIndex:0];
		backgroundImageView_ = newImageView;
	}
	return backgroundImageView_;
}

- (void) setBackgroundImageView:(UIImageView *)backgroundImageView {
	if (backgroundImageView_ != backgroundImageView) {
		[backgroundImageView_ removeFromSuperview];
		[self insertSubview:backgroundImageView atIndex:0];
		backgroundImageView_ = backgroundImageView;
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
	maxItemSize_ = CGSizeMake(self.bounds.size.width, kFSQMenuControlMenuItemHeight);
	selectionStyle_ = FSQMenuSelectionStyleDefault;
	itemAlignment_ = INT_MAX;
	selectedIndex_ = UINT_MAX;
	
	UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
	contentView.showsHorizontalScrollIndicator = NO;
	contentView.showsVerticalScrollIndicator = NO;
	contentView.directionalLockEnabled = YES;
	contentView.scrollEnabled = NO;
	contentView.delegate = self;
	[self insertSubview:contentView atIndex:0];
	contentView_ = contentView;
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
	menuItemBounds.size = maxItemSize_;

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
	if (selectedIndex_ != selectedIndex) {
		FSQMenuItemView *currentView = selectedIndex_ < self.itemViews.count ? [self.itemViews objectAtIndex:selectedIndex_] : nil;
		FSQMenuItemView *newView = [self.itemViews objectAtIndex:selectedIndex];

		selectedIndex_ = selectedIndex;	

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
	if (direction_ == FSQMenuDirectionVertical) {
		CGFloat offsetY = 0;
		for (UIView *view in self.itemViews) {
			CGRect itemFrame = CGRectZero;
			itemFrame.origin = CGPointMake(0, offsetY);
			itemFrame.size = maxItemSize_;
			view.frame = itemFrame;
			offsetY += maxItemSize_.height;
		}
		if (offsetY > 0) {
			self.contentView.contentSize = CGSizeMake(self.bounds.size.width, offsetY);
		}

	} else if (direction_ = FSQMenuDirectionHorizontal) {
		CGFloat offsetX = 0;	
		CGFloat deltaX = 0;
		CGFloat deltaY = 0;
		for (FSQMenuItemView *view in self.itemViews) {	
			CGSize fitSize = [view sizeThatFits:maxItemSize_];
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
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}	
}

// ========================================================================== //

#pragma mark - Helpers

- (void) setItemsSelectionStyle:(FSQMenuSelectionStyle)selectionStyle {
	[self.itemViews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		[(FSQMenuItemView *)subview setSelectionStyle:selectionStyle];
	}];
}

- (void) setItemsTextAlignment:(UITextAlignment)textAlignment {
	[self.itemViews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		[(FSQMenuItemView *)subview setTextAlignment:textAlignment];
	}];
}



@end
