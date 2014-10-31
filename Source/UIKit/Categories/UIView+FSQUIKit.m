//
//  UIView+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 4/13/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIView+FSQUIKit.h"
#import "NSObject+FSQFoundation.h"

@implementation UIView (FSQUIKit)

- (id) firstDescendantMemberOfClass:(Class)aClass {
	id descendant = nil;
	for (UIView * subview in self.subviews) {
		if ([subview isMemberOfClass:aClass]) {
			descendant = subview;
			break;
		}
	}
	if (descendant == nil) {
		for (UIView * subview in self.subviews) {
			descendant = [subview firstDescendantMemberOfClass:aClass];
		}
	}
	return descendant;
}

- (id) firstAncestorOfClass:(Class)aClass {
	UIView *ancestor = nil;
	UIView *view = self;
	do {
		if ([view isKindOfClass:aClass]) {
			ancestor = view;
			break;
		}
		view = view.superview;
	} while (view);
	return ancestor;
}

- (id) firstAncestorOfClassNameContaining:(NSString *)classNameFragment options:(NSStringCompareOptions)options {
	UIView *ancestor = nil;
	UIView *view = self;
	do {
		if ([[view className] rangeOfString:classNameFragment options:options].location != NSNotFound) {
			ancestor = view;
			view = nil;
			break;
		}
		view = view.superview;
	} while (view);
	return ancestor;
}

- (id) firstSiblingOfClassNameContaining:(NSString *)classNameFragment options:(NSStringCompareOptions)options {
	UIView *parent = self.superview;
	UIView *sibling = nil;
	do {
		NSArray *siblings = [parent subviews];
		for (UIView *view in siblings) {
			if ([[view className] rangeOfString:classNameFragment options:options].location != NSNotFound) {
				sibling = view;
				parent = nil;
				break;
			}
		}
		if (nil == sibling) {
			parent = parent.superview;
		}
	} while (parent);
	
	return sibling;
}

- (id) firstRespondingSubview {
	if ([self isFirstResponder]) {
		return self;
	}
	id firstResponder = nil;
	for (UIView *subview in self.subviews) {
		if (firstResponder) {
			break;
		}
		if ([subview isFirstResponder]) {
			firstResponder = subview;
		}
		if (nil == firstResponder) {
			firstResponder = [subview firstRespondingSubview];
		}
	}
	return firstResponder;
}

- (NSArray *) descendants {
	NSMutableArray *descendants = [NSMutableArray new];
	[descendants addObjectsFromArray:self.subviews];
	for (UIView *descendant in self.subviews) {
		[descendants addObjectsFromArray:[descendant descendants]];
	}
	return descendants;
}

- (CGAffineTransform) offscreenLeftTransform {
	CGAffineTransform offscreenLeftTransform = CGAffineTransformMakeTranslation(-self.bounds.size.width,0);
	return offscreenLeftTransform;
}

- (CGAffineTransform) offscreenRightTransform {
	CGAffineTransform offscreenRightTransform = CGAffineTransformMakeTranslation(self.bounds.size.width,0);
	return offscreenRightTransform;
}

- (CGAffineTransform) offscreenTopTransform {
	CGAffineTransform offscreenTopTransform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
	return offscreenTopTransform;
}

- (CGAffineTransform) offscreenBottomTransform {
	CGAffineTransform offscreenBottomTransform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
	return offscreenBottomTransform;
}



@end
