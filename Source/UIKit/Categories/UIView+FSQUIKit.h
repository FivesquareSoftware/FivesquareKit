//
//  UIView+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 4/13/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FSQUIKit)

/** Looks down the view hierarchy, starting with the receiver's immediate subviews, and returns the first view that is of the supplied class. */
- (id) firstDescendantMemberOfClass:(Class)aClass;
/** Looks up the view hierarchy, starting with the receiver, and returns the first view that is of the supplied class. */
- (id) firstAncestorOfClass:(Class)aClass;

- (CGAffineTransform) offscreenLeftTransform;
- (CGAffineTransform) offscreenRightTransform;
- (CGAffineTransform) offscreenTopTransform;
- (CGAffineTransform) offscreenBottomTransform;


@end
