//
//  FSQRemoteImageCache.h
//  FivesquareKit
//
//  Created by John Clayton on 5/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSQFoundationConstants.h"


/** A simple disk-backed, in-memory image fetcher/cache inspired by NSURLCache, but keyed 
 *  by URLs instead of NSURLRequests and which—via the #downloadHandler block—allows 
 *  any networking library to be plugged in to the cache to satisfy download requests. 
 *  The cache is compatible with both Mac OS and iOS. On iOS, an instance will respond 
 *  to low-memory warnings by removing all entries in the in-memory cache. The cache 
 *  is managed using a LRU algorithm, and queries are dispatched via GCD for maximum 
 *  throughput. FSQImageCache is completely thread safe.
 * @see UIImageView+FSQUIKit for an interface to image views that uses this cache automatically.
 */
@interface FSQRemoteImageCache : NSObject

@property (nonatomic, strong) NSString *name;


/// Setting this to NO means images will only be stored on disk. Defaults to YES. 
@property (nonatomic) BOOL usesMemoryCache;
/** In bytes, defaults to 0, which means no limit. Setting usesMemoryCache to NO will cause this value to be ignored.
 *  @note On iOS memory warnings will cause the in-memory cache to be dumped 
 */
@property (nonatomic, readonly) NSUInteger memoryCapacity;
/// In bytes, defaults to 0, which means no limit
@property (nonatomic, readonly) NSUInteger diskCapacity;
@property (nonatomic, strong, readonly) NSString *diskPath; ///< On iOS a subdirectory in the caches directory, on Mac OS a full path
@property (nonatomic) BOOL useICloud;
/**
 * When YES, if a URL is passed in to fetchImageForURL:completionHandler: that contains the pattern @<f>x, then the scale is extracted from the URL and when a resulting image is created and returned its scale will be set so that [image scale] will return this value. Useful when you have image URLs that differ only by a scale factor, such as '@2x' and need to have the scale on the returned image set properly so you can make accurate size calculations. The default is YES.
 */
@property (nonatomic) BOOL automaticallyDetectsScale;

@property (nonatomic, readonly) NSUInteger currentMemoryUsage;
@property (nonatomic, readonly) NSUInteger currentDiskUsage;

/** A block that satisfies requests to download an image using any networking library and invokes a completion block when done. */
@property (nonatomic, copy) void(^downloadHandler)(NSURL *imageURL, FSQImageCacheCompletionHandler completionBlock);

/** A block that passes requests to cancel the download of an image to the networking library handling the download. */
@property (nonatomic, copy) void(^cancelationHandler)(NSURL *imageURL);

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)diskPath;

- (BOOL) hasImageForURL:(id)URLOrString;
- (BOOL) hasImageForURL:(id)URLOrString scale:(CGFloat)scale;

/** @see fetchImageForURL:scale:completionHandler: 
 *  If scale is not embedded in the URL, scale = 1 will be assumed.
 */
- (id) fetchImageForURL:(id)URLOrString completionHandler:(FSQImageCacheCompletionHandler)completionHandler;

/** Searches for an image in the in-memory cache and if not found there, then in the disk cache. Finally, will use #downloadHandler to fetch the image from the internet. In all cases, completionHandler is invoked with the found image or an error on the main thread's queue (so it's safe to interact with your UI).
 *  @param URL can be either an NSURL or an NSString representing a URL
 *  @param scale can be used to force an image scale regardless of whether a scale modifier is embedded in the URL or not, or to provide a scale when a scale modifier is missing from the URL.
 *  @returns an identifier that can be passed as 'identifier' to removeHandler:forURL: to remove the registered handler
 */
- (id) fetchImageForURL:(id)URLOrString scale:(CGFloat)scale completionHandler:(FSQImageCacheCompletionHandler)completionHandler;

/** If a caller goes out of scope or becomes disinterested in a fetched image but still wants the fetch to continue in the background, it can remove it's handler from the callbacks by calling thsi method. */
- (void) removeHandler:(id)identifier forURL:(id)URLOrString;

/** Calls #cancellationHandler with the supplied URL to cancel a download of the image if it is in progress. In-memory and disk cache fetches are not cancellable. */
- (void) cancelFetchForURL:(id)URLOrString;

/** Removes the image from the memory and disk caches.
 *  @param URLOrString can be either an NSURL or an NSString representing a URL
 */
- (void) removeImageForURL:(id)URLOrString;


@end
