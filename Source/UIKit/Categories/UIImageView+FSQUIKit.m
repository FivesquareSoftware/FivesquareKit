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
		automaticallyRequestsScaledImageNumber = [NSNumber numberWithBool:YES];
		[self setAutomaticallyRequestsScaledImage:YES];
	}
	return [automaticallyRequestsScaledImageNumber boolValue];
}

- (void) setAutomaticallyRequestsScaledImage:(BOOL)automaticallyRequestsScaledImage {
	NSNumber *automaticallyRequestsScaledImageNumber = [NSNumber numberWithBool:automaticallyRequestsScaledImage];
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

- (void) setImageWithContentsOfURL:(id)URL cache:(FSQImageCache *)cache completionBlock:(void(^)())block {
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
	
	id URLWithScale = URL;
	CGFloat scale = [[UIScreen mainScreen] scale];
	if (self.automaticallyRequestsScaledImage && scale != 1.f) {
		NSString *key = [URL description];
		NSError *regexError = nil;
		NSRegularExpression *URLExpression = [NSRegularExpression regularExpressionWithPattern:kFSQImageCacheURLWithOptionalScaleExpression options:0 error:&regexError];
		NSRange keyRange = NSMakeRange(0, key.length);
		NSTextCheckingResult *match = [URLExpression firstMatchInString:key options:0 range:keyRange];		
		NSRange scaleRange = [match rangeAtIndex:kFSQImageCacheURLComponentScaleFactor];
		if (match && scaleRange.location == NSNotFound) {	// if there is no scale in the URL already		
			NSString *template;
			if ([match rangeAtIndex:kFSQImageCacheURLComponentExtension].location != NSNotFound) {
				template = [NSString stringWithFormat:@"$%d@%.0fx$%d",kFSQImageCacheURLComponentBase,scale,kFSQImageCacheURLComponentExtension];
			} else {
				template = [NSString stringWithFormat:@"$%d@%.0fx",kFSQImageCacheURLComponentBase,scale];
			}
			// insert scale into the URL
			URLWithScale = [URLExpression stringByReplacingMatchesInString:key options:0 range:keyRange withTemplate:template];
		}
	}		
	
	[cache fetchImageForURL:URLWithScale completionHandler:completionHandler];
}



@end
