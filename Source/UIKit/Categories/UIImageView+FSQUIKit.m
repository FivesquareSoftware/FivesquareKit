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
static const NSString *kUIImageView_FSQUIKit_URL = @"UIImageView_FSQUIKit_URL";
static const NSString *kUIImageView_FSQUIKit_completionTicket = @"UIImageView_FSQUIKit_completionTicket";


@implementation UIImageView (FSQUIKit)

// ========================================================================== //

#pragma mark - Properties



@dynamic cache;
- (FSQRemoteImageCache *) cache {
	FSQRemoteImageCache *cache = (FSQRemoteImageCache *)objc_getAssociatedObject(self, &kUIImageView_FSQUIKit_Cache);
	return cache;
}

- (void) setCache:(FSQRemoteImageCache *)cache {
	objc_setAssociatedObject(self, &kUIImageView_FSQUIKit_Cache, cache, OBJC_ASSOCIATION_ASSIGN);
}

@dynamic automaticallyRequestsScaledImage;
- (BOOL) automaticallyRequestsScaledImage {
	NSNumber *automaticallyRequestsScaledImageNumber = (NSNumber *)objc_getAssociatedObject(self, &kUIImageView_FSQUIKit_automaticallyRequestsScaledImage);
	if (automaticallyRequestsScaledImageNumber == nil) {
		automaticallyRequestsScaledImageNumber = @(NO);
		[self setAutomaticallyRequestsScaledImage:NO];
	}
	return [automaticallyRequestsScaledImageNumber boolValue];
}

- (void) setAutomaticallyRequestsScaledImage:(BOOL)automaticallyRequestsScaledImage {
	NSNumber *automaticallyRequestsScaledImageNumber = @(automaticallyRequestsScaledImage);
	objc_setAssociatedObject(self, &kUIImageView_FSQUIKit_automaticallyRequestsScaledImage, automaticallyRequestsScaledImageNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic URL;
- (id) URL {
	id URL = objc_getAssociatedObject(self, &kUIImageView_FSQUIKit_URL);
	return URL;
}

- (void) setURL:(id)URL {
	objc_setAssociatedObject(self, &kUIImageView_FSQUIKit_URL, URL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@dynamic completionTicket;
- (id) completionTicket {
	id ticket = objc_getAssociatedObject(self, &kUIImageView_FSQUIKit_completionTicket);
	return ticket;
}

- (void) setCompletionTicket:(id)completionTicket {
	objc_setAssociatedObject(self, &kUIImageView_FSQUIKit_completionTicket, completionTicket, OBJC_ASSOCIATION_RETAIN);
}

// ========================================================================== //

#pragma mark - Object


//FIXME: do not like putting a dealloc in a category ... even considering the new ARC behavior
- (void)dealloc {
	if (self.cache && self.URL && self.completionTicket) {
		[self.cache removeHandler:self.completionTicket forURL:self.URL];
		self.completionTicket = nil;
	}
}

// ========================================================================== //

#pragma mark - Loaders



- (void) setImageWithContentsOfURL:(id)URL {
	FSQAssert(self.cache != nil, @"Tried to load an image from a non-existent cache!");
	[self setImageWithContentsOfURL:URL cache:self.cache completionBlock:nil];
}

- (void) setImageWithContentsOfURL:(id)URL completionBlock:(void(^)(BOOL success))block {
	FSQAssert(self.cache != nil, @"Tried to load an image from a non-existent cache!");
	[self setImageWithContentsOfURL:URL cache:self.cache completionBlock:block];
}

- (void) setImageWithContentsOfURL:(id)URLOrString cache:(FSQRemoteImageCache *)imageCache completionBlock:(void(^)(BOOL success))block {

	// Cancel/reject any completion handlers that might be out there already
	if (self.URL && self.completionTicket) {
		[imageCache removeHandler:self.completionTicket forURL:self.URL];
		self.completionTicket = nil;
	}
	
	
	// Get the arg into an NSURL and do a little validation
	NSURL *URL;
	
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
		
	// Check if we need to add scale
	NSURL *URLWithScale = URL;
	
	CGFloat scale = [[UIScreen mainScreen] scale];
	if (self.automaticallyRequestsScaledImage && scale > 1.f) {
		// Is scale set already?
		if ([NSString isEmpty:[URL scaleModifier]]) { 
			URLWithScale = [URL URLBySettingScale:scale];
		} 
	}
	
	// Set up a completion handler that checks if our URL is still the same as what was fetched
	void (^completionHandler)(id, NSError *) = ^(id image, NSError *error){
		id fetchedURL = URLWithScale; // capture the URL we're fetching here

		if (error) {
			FLogError(error, @"Could not load image");
		}
		if ([fetchedURL isEqual:self.URL]) { // check if the image view is no longer interested
			BOOL success = image != nil;
			
			if (success) {
				[UIView animateWithDuration:.265 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
					self.image = image;
				} completion:^(BOOL finished) {
					
				}];
			}
			if (block) {
				block(success);
			}
		}
		self.completionTicket = nil;
	};
	
	self.URL = URLWithScale;
	id ticket = [imageCache fetchImageForURL:self.URL scale:scale completionHandler:completionHandler];
	self.completionTicket = ticket;

}


@end
