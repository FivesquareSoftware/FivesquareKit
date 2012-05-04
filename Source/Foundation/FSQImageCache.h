//
//  FSQImageCache.h
//  FivesquareKit
//
//  Created by John Clayton on 5/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FSQImageCacheCompletionHandler)(id image, NSError *error);


/** A simple disk-backed, in-memory image cache inspired by NSURLCache, but keyed 
 *  by URLs instead of NSURLRequests and which—via the #downloadHandler block—allows 
 *  any networking library to be plugged in to the cache to satisfy download requests. 
 *  The cache is compatible with both Mac OS and iOS. On iOS, an instance will respond 
 *  to low-memory warnings by removing all entries in the in-memory cache. The cache 
 *  is managed using a LRU algorithm, and queries are dispatched via GCD for maximum 
 *  throughput. FSQImageCache is completely thread safe.
 * @see UIImageView+FSQUIKit for an interface to image views that uses this cache automatically.
 */
@interface FSQImageCache : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, readonly) NSUInteger memoryCapacity; ///< In bytes, defaults to 0, which means no limit. However, on iOS memory warnings will cause the in-memory cache to be dumped
@property (nonatomic, readonly) NSUInteger diskCapacity; ///< In bytes, defaults to 0, which means no limit
@property (nonatomic, strong, readonly) NSString *diskPath; ///< On iOS a subdirectory in the caches directory, on Mac OS a full path

@property (nonatomic, readonly) NSUInteger currentMemoryUsage;
@property (nonatomic, readonly) NSUInteger currentDiskUsage;

/** A block that handles requests to download an image and invoke a completion block when done. */
@property (nonatomic, copy) void(^downloadHandler)(NSURL *imageURL, FSQImageCacheCompletionHandler completionBlock);

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)diskPath;

/** Searches for an image in the in-memory cache, and if not found in the disk cache. Finally, will use #downloadHandler to fetch the image from the internet. In all cases, completionHandler is invoked with the found image or an error on the main thread's queue (so it's safe to interact with your UI). 
 *  @param key can be either an NSURL or an NSString representing a URL
 */
- (void) fetchImageForURL:(id)key completionHandler:(FSQImageCacheCompletionHandler)completionHandler;

/**
 *  @param key can be either an NSURL or an NSString representing a URL
 */
- (void) removeImageForURL:(id)key;


@end
