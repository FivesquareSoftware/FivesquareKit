//
//  UIView+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 4/13/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIView+FSQUIKit.h"

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


@end
