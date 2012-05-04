//
//  UIImageView+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 5/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIImageView+FSQUIKit.h"

#import <objc/runtime.h>

#import "FSQLogging.h"
#import "FSQAsserter.h"

static const NSString *kUIImageView_FSQUIKit_Cache = @"UIImageView_FSQUIKit_Cache";


@implementation UIImageView (FSQUIKit)

@dynamic cache;
- (FSQImageCache *) cache {
	FSQImageCache *cache = (FSQImageCache *)objc_getAssociatedObject(self, &kUIImageView_FSQUIKit_Cache);
	return cache;
}

- (void) setCache:(FSQImageCache *)cache {
	objc_setAssociatedObject(self, &kUIImageView_FSQUIKit_Cache, cache, OBJC_ASSOCIATION_ASSIGN);
}

- (void) setImageWithContentsOfURL:(id)URL {
	FSQAssert(self.cache != nil, @"Tried to load an image from a non-existent cache!");
	[self setImageWithContentsOfURL:URL cache:self.cache completionBlock:nil];
}

- (void) setImageWithContentsOfURL:(id)URL completionBlock:(void(^)())block {
	FSQAssert(self.cache != nil, @"Tried to load an image from a non-existent cache!");
	[self setImageWithContentsOfURL:URL cache:self.cache completionBlock:block];
}

- (void) setImageWithContentsOfURL:(id)URL cache:(FSQImageCache *)cache completionBlock:(void(^)())block {
	[cache fetchImageForURL:URL completionHandler:^(id image, NSError *error) {
		if (error) {
			FLogError(error, @"Could not load image");
		} else {
			self.image = image;
			if (block) {
				block();
			}
		}
	}];
}



@end
