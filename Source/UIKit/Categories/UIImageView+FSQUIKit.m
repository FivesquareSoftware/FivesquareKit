//
//  UIImageView+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 5/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIImageView+FSQUIKit.h"

#import "FSQLogging.h"
#import "FSQImageCache.h"

@implementation UIImageView (FSQUIKit)

- (void) setImageWithContentsOfURL:(id)URL cache:(FSQImageCache *)cache {
	[cache fetchImageForURL:URL completionHandler:^(id image, NSError *error) {
		if (error) {
			FLogError(error, @"Could not load image");
		} else {
			self.image = image;
		}
	}];
}

@end
