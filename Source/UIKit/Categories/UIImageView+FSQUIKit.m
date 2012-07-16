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
#import "FSQFoundationConstants.h"
#import "NSString+FSQFoundation.h"
#import "NSURL+FSQFoundation.h"

static const NSString *kUIImageView_FSQUIKit_Cache = @"UIImageView_FSQUIKit_Cache";
static const NSString *kUIImageView_FSQUIKit_automaticallyRequestsScaledImage = @"UIImageView_FSQUIKit_Cache";


@implementation UIImageView (FSQUIKit)

@dynamic cache;
- (FSQImageCache *) cache {
	FSQImageCache *cache = (FSQImageCache *)objc_getAssociatedObject(self, &kUIImageView_FSQUIKit_Cache);
	return cache;
}

- (void) setCache:(FSQImageCache *)cache {
	objc_setAssociatedObject(self, &kUIImageView_FSQUIKit_Cache, cache, OBJC_ASSOCIATION_ASSIGN);
}

@dynamic automaticallyRequestsScaledImage;
- (BOOL) automaticallyRequestsScaledImage {
	NSNumber *automaticallyRequestsScaledImageNumber = (NSNumber *)objc_getAssociatedObject(self, &kUIImageView_FSQUIKit_automaticallyRequestsScaledImage);
	if (automaticallyRequestsScaledImageNumber == nil) {
		automaticallyRequestsScaledImageNumber = @YES;
		[self setAutomaticallyRequestsScaledImage:YES];
	}
	return [automaticallyRequestsScaledImageNumber boolValue];
}

- (void) setAutomaticallyRequestsScaledImage:(BOOL)automaticallyRequestsScaledImage {
	NSNumber *automaticallyRequestsScaledImageNumber = @(automaticallyRequestsScaledImage);
	objc_setAssociatedObject(self, &kUIImageView_FSQUIKit_automaticallyRequestsScaledImage, automaticallyRequestsScaledImageNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void) setImageWithContentsOfURL:(id)URL {
	FSQAssert(self.cache != nil, @"Tried to load an image from a non-existent cache!");
	[self setImageWithContentsOfURL:URL cache:self.cache completionBlock:nil];
}

- (void) setImageWithContentsOfURL:(id)URL completionBlock:(void(^)())block {
	FSQAssert(self.cache != nil, @"Tried to load an image from a non-existent cache!");
	[self setImageWithContentsOfURL:URL cache:self.cache completionBlock:block];
}

- (void) setImageWithContentsOfURL:(id)URLOrString cache:(FSQImageCache *)cache completionBlock:(void(^)())block {
	void (^completionHandler)(id, NSError *) = ^(id image, NSError *error){
		if (error) {
			FLogError(error, @"Could not load image");
		} else {
			self.image = image;
			if (block) {
				block();
			}
		}
	};
	
	NSURL *URL;
	// Get the arg into an NSURL and do a little validation
	
	if ([URLOrString isKindOfClass:[NSString class]]) {
		NSString *trimmedString = [URLOrString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (NO == [NSString isEmpty:trimmedString]) {
			URL = [NSURL URLWithString:trimmedString];
		}
	} else {
		URL = URLOrString;
	}
	
	if (URL == nil || [NSString isEmpty:[URL description]]) {
		FLog(@"Not loading image from empty URL");
		return;
	}
	
	FSQAssert([URL isKindOfClass:[NSURL class]],@"URL must be either an NSString or an NSURL: %@",URL);
	if (NO == [URL isKindOfClass:[NSURL class]]) {
		return;
	}

	NSURL *URLWithScale = URL;
	
	// Check if we need to add scale
	
	CGFloat scale = [[UIScreen mainScreen] scale];
	if (self.automaticallyRequestsScaledImage && scale > 1.f) {
		
		// Is scale set already?
		
		if ([NSString isEmpty:[URL scaleModifier]]) { 
			URLWithScale = [URL URLBySettingScale:scale];
		} 
	}


	[cache fetchImageForURL:URLWithScale completionHandler:completionHandler];
}



@end
