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

@property (nonatomic, unsafe_unretained) FSQImageCache *cache;

/** Whether scale signifiers (e.g. '@2x') are appended to filenames in URLS. The default is YES.
 *  @examples
 *    - foo.png will become foo@2x.png if the device scale is 2.
 *    - foo.png will remain unchanged if the device scale is 1.
 */
@property (nonatomic) BOOL automaticallyRequestsScaledImage; 

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
 *  @param URLOrString may be an NSURL or an NSString representing an URL
 */
- (void) setImageWithContentsOfURL:(id)URLOrString cache:(FSQImageCache *)cache completionBlock:(void(^)())block;

@end
