//
//  UIImageView+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 5/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSQImageCache;

@interface UIImageView (FSQUIKit)

- (void) setImageWithContentsOfURL:(id)URL cache:(FSQImageCache *)cache;

@end
