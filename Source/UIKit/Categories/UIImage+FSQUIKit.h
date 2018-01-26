//
//  UIImage+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 11/18/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FSQUIKit)

- (CGSize) sizeThatFits:(CGSize)fitSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode;
- (UIImage *) imageSizedToFit:(CGSize)fitSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode;

@end
