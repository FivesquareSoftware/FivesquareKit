//
//  UIImageView+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 5/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQImageCache.h"

@interface UIImageView (FSQUIKit)

@property (nonatomic, weak) FSQImageCache *cache;

/** Sets the receiver's image from the URL using #cache.
 *  @throws an exception if #cache is not set
 *  @see setImageWithContentsOfURL:cache:completionBlock: 
 */
- (void) setImageWithContentsOfURL:(id)URL;

/** Sets the receiver's image from the URL using #cache.
 *  @throws an exception if #cache is not set
 *  @see setImageWithContentsOfURL:cache:completionBlock: 
 */
- (void) setImageWithContentsOfURL:(id)URL completionBlock:(void(^)())block;

/** Sets the receiver's image from a URL, first checking in the specified cache before fetching it from the internet. 
 *  @param completionBlock runs if the image is loaded successfully
 *  @param URL may be an NSURL or an NSString representing an URL
 */
- (void) setImageWithContentsOfURL:(id)URL cache:(FSQImageCache *)cache completionBlock:(void(^)())block;

@end
