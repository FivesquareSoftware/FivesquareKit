//
//  FSQImageCache.m
//  FivesquareKit
//
//  Created by John Clayton on 5/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQImageCache.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "FSQSandbox.h"
#import "FSQAsserter.h"
#import "FSQLogging.h"
#import "FSQMacros.h"
#import "NSString+FSQFoundation.h"
#import "NSURL+FSQFoundation.h"



// A wraper for cache entries that lets us do LRU
@interface FSQImageCacheEntry : NSObject
@property (nonatomic, strong) id image;
@property (nonatomic, strong) NSDate *lastAccessDate;
+ (id) withImage:(id)image;
@end

@implementation FSQImageCacheEntry
@synthesize image = _image, lastAccessDate = _lastAccessDate;
+ (id) withImage:(id)image {
	FSQImageCacheEntry *entry = [self new];
	entry.image = image;
	entry.lastAccessDate = [NSDate date];
	return entry;
}
@end



@interface FSQImageCache ()

@property (nonatomic, strong) NSMutableDictionary *cache;
//#if TARGET_OS_IPHONE && !defined(__IPHONE_6_0)
//@property (nonatomic, assign) dispatch_queue_t cacheQueue;
//#else
@property (nonatomic, strong) dispatch_queue_t cacheQueue __attribute__((NSObject));
//#endif
@property (nonatomic, strong) NSMutableDictionary *completionHandlersByKey;
@property (nonatomic, strong) NSMutableSet *currentDownloads;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSString *cachePath;

@end

@implementation FSQImageCache

// ========================================================================== //

#pragma mark - Properties


- (NSString *) cachePath {
	if (_cachePath == nil) {
		BOOL created;
		NSError *error = nil;
#if TARGET_OS_IPHONE
		_cachePath = [[FSQSandbox cachesDirectory] stringByAppendingPathComponent:_diskPath];
#else
		_cachePath = [_diskPath copy];
#endif
		NSFileManager *fm = [NSFileManager new];
		created = [fm createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:NULL error:&error];
		if (NO == created) {
			FLogError(error, @"Could not create image cache");
		};
	}
	return _cachePath;
}


// ========================================================================== //

#pragma mark - Object


- (void)dealloc {
//#ifndef __IPHONE_6_0
//    dispatch_release(_cacheQueue);
//#endif
#if TARGET_OS_IPHONE
	[[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)diskPath {
	self = [super init];
	diskPath = [diskPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([NSString isEmpty:diskPath]) {
		FSQAssert(NO, @"diskPath cannot be nil or empty");
		self = nil;
	}
	if (self) {
		_memoryCapacity = memoryCapacity;
		_diskCapacity = diskCapacity;
		_diskPath = diskPath;
		_automaticallyDetectsScale = YES;
		
		_cache = [NSMutableDictionary new];
		_cacheQueue = dispatch_queue_create([[NSString stringWithFormat:@"FSQImageCache.%p",self] UTF8String], DISPATCH_QUEUE_SERIAL);
		_completionHandlersByKey = [NSMutableDictionary new];
		_currentDownloads = [NSMutableSet new];
#if TARGET_OS_IPHONE
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
		// build a cached file list and calculate disk usage before any requests come in 
		dispatch_async(_cacheQueue, ^{
			NSFileManager *fm = [NSFileManager new];
			NSError *error = nil;
			
			NSArray *files = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.cachePath] 
							   includingPropertiesForKeys:@[NSURLContentAccessDateKey,NSURLFileSizeKey] 
												  options:NSDirectoryEnumerationSkipsHiddenFiles 
													error:&error];
			if (error) {
				FLogError(error, @"Could not build file list!");
			} else {
				for (NSURL *file in files) {
					// access entries
					FSQImageCacheEntry *entry = [FSQImageCacheEntry new];
					entry.image = file;
					id lastAccessDate;
					if ([file getResourceValue:&lastAccessDate forKey:NSURLContentAccessDateKey error:&error]) {
						entry.lastAccessDate = lastAccessDate;
						[_fileList addObject:entry];
					}
					FSQAssert(error == nil, @"Couldn't get last access date");

					
					// disk usage
					id fileSize;
					if ([file getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
						NSUInteger size = [fileSize unsignedIntegerValue];
						_currentDiskUsage += size;
					} 
					FSQAssert(error == nil, @"Couldn't get file size");
				}
			}
		});
	}
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ name=%@ diskPath=%@ currentMemoryUsage=%@",[super description], _name, _diskPath, @(_currentMemoryUsage)];
}


// ========================================================================== //

#pragma mark - Public




- (id) fetchImageForURL:(id)URLOrString completionHandler:(FSQImageCacheCompletionHandler)completionHandler {
	return [self fetchImageForURL:URLOrString scale:0 completionHandler:completionHandler];
}

- (id) fetchImageForURL:(id)URLOrString scale:(CGFloat)scaleOverride completionHandler:(FSQImageCacheCompletionHandler)completionHandler {
//	FLog(@"fetchImageForURL:%@ scale:%@",URLOrString,@(scaleOverride));

	NSURL *key = [self keyForKeyObject:URLOrString];
	
	if (key == nil || [NSString isEmpty:[key description]]) {
		FLog(@"'%@' is not a valid URL-like object",[URLOrString description]);
		return nil;
	}

	
	NSURL *unscaledKey = nil;
	NSURL *storageKey = nil;
	float scale FSQ_MAYBE_UNUSED = 1;
	if (_automaticallyDetectsScale) {
		scale = [self scaleForKey:key descaledKey:&unscaledKey];
	} 
	else {
		unscaledKey = key;
	}
	
	if (scaleOverride > 0) {
		scale = scaleOverride;
		storageKey = [key URLBySettingScale:scale];
	}
	else {
		storageKey = key;
	}
	
	NSString *ticket = [NSString stringWithFormat:@"%@ %@",[key absoluteString],[[NSDate date] description]];

	// don't block the main thread with disk scans etc..
	// all cache access is piped through our serial queue so there are no concurrency issues
	dispatch_async(_cacheQueue, ^{
		
		// register our handler for the key
		[self addHandler:completionHandler forKey:key ticket:ticket];
		
		// check the memory cache for the image
		id image = [[_cache objectForKey:key] image];
		if (image) {
			[self dispatchCompletionHandlersForKey:key withImage:image error:nil];
		} 
		// check the disk cache for the image
		else { 
#if TARGET_OS_IPHONE
			NSString *imagePath = [self cachePathForKey:unscaledKey]; // use the unscaled path because imageWithContentsOfFile: gets the right version for us
			image = [UIImage imageWithContentsOfFile:imagePath];
#else
			//TODO: load image from disk for mac os
#endif
			if (image) {
				[self dispatchCompletionHandlersForKey:key withImage:image error:nil];
			}
			// begin downloading it if noone else is
			else if ([self beginDownload:key]) {
				_downloadHandler(key,^(id downloadedImage, NSError *downloadError){
					if (downloadedImage && downloadError == nil) {
#if TARGET_OS_IPHONE
						if (scale > 1) {
							CGImageRef cgImage = [(UIImage *)downloadedImage CGImage];
							downloadedImage = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
						}
#else
						//TODO: will Mac OS support @2x?
#endif
						[self storeImage:downloadedImage forKey:key storageKey:storageKey];
						[self dispatchCompletionHandlersForKey:key withImage:downloadedImage error:nil];
					} else {
						[self dispatchCompletionHandlersForKey:key withImage:nil error:downloadError];
					}
					[_currentDownloads removeObject:key];
				});
			}
		}
	});
	
	return ticket;
}

- (void) removeHandler:(id)identifier forURL:(id)URLOrString {
	NSURL *key = [self keyForKeyObject:URLOrString];
	dispatch_async(_cacheQueue, ^{
		NSMutableDictionary *handlersForKey = [_completionHandlersByKey objectForKey:key];
		if (handlersForKey) {
			[handlersForKey removeObjectForKey:identifier];
		}
	});
}

- (void) cancelFetchForURL:(id)URLOrString {
	NSURL *key = [self keyForKeyObject:URLOrString];
	
	if (key == nil || [NSString isEmpty:[key description]]) {
		FLog(@"'%@' is not a valid URL-like object",[URLOrString description]);
		return;
	}

	dispatch_async(_cacheQueue, ^{
		[_completionHandlersByKey removeObjectForKey:key];
		if (_cancelationHandler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				_cancelationHandler(URLOrString);
			});
		}
	});
}

- (void) removeImageForURL:(id)URLOrString {
	FLog(@"removeImageForURL: %@",URLOrString);
	NSURL *key = [self keyForKeyObject:URLOrString];
	dispatch_async(_cacheQueue, ^{
		[_cache removeObjectForKey:key];
		NSFileManager *fm = [NSFileManager new];
		NSError *error = nil;
		if (NO == [fm removeItemAtPath:[self cachePathForKey:key] error:&error]) {
			FLogError(error, @"Could not remove entry for %@",URLOrString);
		};
	});
}




// ========================================================================== //

#pragma mark - Private

- (NSURL *) keyForKeyObject:(id)URLOrString {
	NSURL *key = nil;
	if ([URLOrString isKindOfClass:[NSString class]]) {
		NSString *trimmedString = [URLOrString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([trimmedString length] > 0) {
			key = [NSURL URLWithString:URLOrString];
		}
	} else if ([URLOrString isKindOfClass:[NSURL class]]) {
		key = URLOrString;
	}
	return key;
}


- (float) scaleForKey:(NSURL *)URL descaledKey:(NSURL **)descaledKeyPtr {
	if (descaledKeyPtr) {
		*descaledKeyPtr = [URL URLByDeletingScale];
	}
	return [URL scale];
}

- (NSString *) cachePathForKey:(NSURL *)URL {
//	FLog(@"URL:%@",URL);

	NSString *basename = [[[[URL path] lastPathComponent] stringByDeletingPathExtension] stringByDeletingScaleModifier];
	NSString *scaleModifier = [URL scaleModifier];
	NSString *extension = [URL pathExtension];
	
	
	NSString *cachePath = [self.cachePath stringByAppendingPathComponent:[basename MD5Hash]];
	if (NO == [NSString isEmpty:scaleModifier]) {
		cachePath = [cachePath stringByAppendingString:scaleModifier];
	}
	if (NO == [NSString isEmpty:extension]) {
		cachePath = [cachePath stringByAppendingPathExtension:extension];
	}
//	FLog(@"cachePath: %@",cachePath);
	return cachePath;
}

- (void) addHandler:(FSQImageCacheCompletionHandler)handler forKey:(NSURL *)key ticket:(id)ticket {
	NSMutableDictionary *handlersForKey = [_completionHandlersByKey objectForKey:key];
	if (handlersForKey == nil) {
		handlersForKey = [NSMutableDictionary new];
		[_completionHandlersByKey setObject:handlersForKey forKey:key];
	}
	[handlersForKey setObject:[handler copy] forKey:ticket];
}

- (void) dispatchCompletionHandlersForKey:(NSURL *)key withImage:(id)image error:(NSError *)error {
	NSArray *handlers = [[_completionHandlersByKey objectForKey:key] allValues];
	for (FSQImageCacheCompletionHandler handler in handlers) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(image,error);
		});
	}
	[_completionHandlersByKey removeObjectForKey:key];
}

- (BOOL) beginDownload:(NSURL *)key {
	FSQAssert(_downloadHandler != nil, @"downloadHandler cannot be nil!");
	if (_downloadHandler == nil) {
		return NO;
	}
	if (NO == [_currentDownloads containsObject:key]) {
		[_currentDownloads addObject:key];
		return YES;
	}
	return NO;
}
		
- (void) storeImage:(id)image forKey:(NSURL *)key storageKey:(NSURL *)storageKey {
//	FLog(@"storeImage:forURL: %@",key);
	
	// all cache access is piped through our serial queue so there are no concurrency issues
	dispatch_async(_cacheQueue, ^{
		
		// trim memory cache if over size
#if TARGET_OS_IPHONE
		NSData *imageData = UIImagePNGRepresentation(image);
#else
		NSData *imageData = nil; //TODO: get image data for mac os
#endif
		NSUInteger imageSize = [imageData length];
		
		__block NSUInteger newMemoryUsage = _currentMemoryUsage + imageSize;
		if (_memoryCapacity != 0 && newMemoryUsage > _memoryCapacity) {
			FLog(@"%@ - ** Memory capacity (%@) exceeded, purging cache",self,@(_currentMemoryUsage));
			NSArray *sortedCacheKeys = [_cache keysSortedByValueUsingComparator:^NSComparisonResult(FSQImageCacheEntry *obj1, FSQImageCacheEntry *obj2) {
				return [obj2.lastAccessDate compare:obj1.lastAccessDate]; // Descending by date
			}];
			
			[sortedCacheKeys enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id cacheKey, NSUInteger idx, BOOL *stop) {
				id cachedImage FSQ_MAYBE_UNUSED = [[_cache objectForKey:cacheKey] image];
#if TARGET_OS_IPHONE
				NSData *entryData = UIImagePNGRepresentation(cachedImage);
#else
				NSData *entryData = nil; //TODO: get image data for mac os
#endif				
				[_cache removeObjectForKey:cacheKey];
				newMemoryUsage -= [entryData length];
				*stop = newMemoryUsage < _memoryCapacity;
			}];
		}
		
		// store in memory cache
		[_cache setObject:[FSQImageCacheEntry withImage:image] forKey:key];
		_currentMemoryUsage = newMemoryUsage;
		
		// trim disk cache if over size
		__block NSUInteger newDiskUsage = _currentDiskUsage + imageSize;
		if (_diskCapacity != 0 && newDiskUsage > _diskCapacity) {
			FLog(@"%@ - ** Disk capacity (%@) exceeded, purging cache",self,@(_currentDiskUsage));

			NSArray *sortedFileList = [_fileList sortedArrayUsingComparator:^NSComparisonResult(FSQImageCacheEntry *obj1, FSQImageCacheEntry *obj2) {
				return [obj2.lastAccessDate compare:obj1.lastAccessDate]; // Descending by date
			}];
			
			[sortedFileList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id file, NSUInteger idx, BOOL *stop) {
				id fileSize;
				NSError *error = nil;
				if ([file getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
					NSUInteger bytes = [fileSize unsignedIntegerValue];
					NSFileManager *fm = [NSFileManager new];
					if ([fm removeItemAtURL:file error:&error]) {
						[_fileList removeObject:file];
						newMemoryUsage -= bytes;
					};
				}
				FSQAssert(error == nil, @"Couldn't get file size");
				*stop = newDiskUsage < _diskCapacity;
			}];
			
		}
		
		// store in disk cache
		NSError *writeError = nil;
		if (NO == [imageData writeToFile:[self cachePathForKey:storageKey] options:NSDataWritingAtomic error:&writeError]) {
			FLogError(writeError, @"Could not write image to disk");
		}
	});
}

		 
// ========================================================================== //

#pragma mark - Notifications


#if TARGET_OS_IPHONE

- (void) didReceiveMemoryWarning:(NSNotification *)notification {
	FLog(@"** LOW MEMORY ** -- IMAGE CACHE DUMPING CONTENTS -- %@",[self description]);
	dispatch_async(_cacheQueue, ^{
		[_cache removeAllObjects];
	});
}

#endif		 

@end




