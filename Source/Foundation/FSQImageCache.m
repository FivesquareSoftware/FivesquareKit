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
@synthesize image=image_, lastAccessDate=lastAccessDate_;
+ (id) withImage:(id)image {
	FSQImageCacheEntry *entry = [self new];
	entry.image = image;
	entry.lastAccessDate = [NSDate date];
	return entry;
}
@end



@interface FSQImageCache ()

@property (nonatomic, strong) NSMutableDictionary *cache;
#ifndef __IPHONE_6_0
@property (nonatomic, assign) dispatch_queue_t cacheQueue;
#else
@property (nonatomic, strong) dispatch_queue_t cacheQueue;
#endif
@property (nonatomic, strong) NSMutableDictionary *completionHandlersByKey;
@property (nonatomic, strong) NSMutableSet *currentDownloads;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSString *cachePath;

- (NSURL *) keyForKeyObject:(id)URLOrString;
- (float) scaleForKey:(NSURL *)URL descaledKey:(NSURL **)descaledKeyPtr;
- (NSString *) cachePathForKey:(NSURL *)key;
- (void) addHandler:(FSQImageCacheCompletionHandler)handler forKey:(NSURL *)key;
- (void) dispatchCompletionHandlersForKey:(NSURL *)key withImage:(id)image error:(NSError *)error;
- (BOOL) beginDownload:(NSURL *)key;
- (void) storeImage:(id)image forKey:(NSURL *)key;
@end

@implementation FSQImageCache

// ========================================================================== //

#pragma mark - Properties

@synthesize name=name_;
@synthesize memoryCapacity=memoryCapacity_;
@synthesize diskCapacity=diskCapacity_;
@synthesize diskPath=diskPath_;
@synthesize automaticallyDetectsScale=automaticallyDetectsScale_;
@synthesize currentMemoryUsage=currentMemoryUsage_;
@synthesize currentDiskUsage=currentDiskUsage_;
@synthesize downloadHandler=downloadHandler_;
@synthesize cancelationHandler=cancelationHandler_;

// Private

@synthesize cache=cache_;
@synthesize cacheQueue=cacheQueue_;
@synthesize completionHandlersByKey=completionHandlersByKey_;
@synthesize currentDownloads=currentDownloads_;
@synthesize fileList=fileList_;
@synthesize cachePath=cachePath_;


- (NSString *) cachePath {
	if (cachePath_ == nil) {
		BOOL created;
		NSError *error = nil;
#if TARGET_OS_IPHONE
		cachePath_ = [[FSQSandbox cachesDirectory] stringByAppendingPathComponent:diskPath_];
#else
		cachePath_ = [diskPath_ copy];
#endif
		NSFileManager *fm = [NSFileManager new];
		created = [fm createDirectoryAtPath:cachePath_ withIntermediateDirectories:YES attributes:NULL error:&error];
		if (NO == created) {
			FLogError(error, @"Could not create image cache");
		};
	}
	return cachePath_;
}


// ========================================================================== //

#pragma mark - Object


- (void)dealloc {
#ifndef __IPHONE_6_0
    dispatch_release(cacheQueue_);
#endif
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
		memoryCapacity_ = memoryCapacity;
		diskCapacity_ = diskCapacity;
		diskPath_ = diskPath;
		automaticallyDetectsScale_ = YES;
		
		cache_ = [NSMutableDictionary new];
		cacheQueue_ = dispatch_queue_create([[NSString stringWithFormat:@"FSQImageCache.%p",self] UTF8String], DISPATCH_QUEUE_SERIAL);
		completionHandlersByKey_ = [NSMutableDictionary new];
		currentDownloads_ = [NSMutableSet new];
#if TARGET_OS_IPHONE
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
		// build a cached file list and calculate disk usage before any requests come in 
		dispatch_async(cacheQueue_, ^{
			NSFileManager *fm = [NSFileManager new];
			NSError *error = nil;
			
			NSArray *files = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.cachePath] 
							   includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLContentAccessDateKey,NSURLFileSizeKey,nil] 
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
						[fileList_ addObject:entry];
					}
					FSQAssert(error == nil, @"Couldn't get last access date");

					
					// disk usage
					id fileSize;
					if ([file getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
						NSUInteger size = [fileSize unsignedIntegerValue];
						currentDiskUsage_ += size;
					} 
					FSQAssert(error == nil, @"Couldn't get file size");
				}
			}
		});
	}
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ name=%@ diskPath=%@ currentMemoryUsage=%u",[super description], name_, diskPath_, currentMemoryUsage_];
}


// ========================================================================== //

#pragma mark - Public




- (void) fetchImageForURL:(id)URLOrString completionHandler:(FSQImageCacheCompletionHandler)completionHandler {

	NSURL *key = [self keyForKeyObject:URLOrString];
	
	if (key == nil || [NSString isEmpty:[key description]]) {
		FLog(@"'%@' is not a valid URL-like object",[URLOrString description]);
		return;
	}

	
	NSURL *descaledKey = nil;
	float scale FSQ_MAYBE_UNUSED = 1;
	if (automaticallyDetectsScale_) {
		scale = [self scaleForKey:key descaledKey:&descaledKey];
	} 
	else {
		descaledKey = key;
	}
	
	// don't block the main thread with disk scans etc..
	// all cache access is piped through our serial queue so there are no concurrency issues
	dispatch_async(cacheQueue_, ^{
		
		// register our handler for the key
		[self addHandler:completionHandler forKey:key];
		
		// check the memory cache for the image
		id image = [[cache_ objectForKey:key] image];
		if (image) {
			[self dispatchCompletionHandlersForKey:key withImage:image error:nil];
		} 
		// check the disk cache for the image
		else { 
#if TARGET_OS_IPHONE
			NSString *imagePath = [self cachePathForKey:descaledKey]; // use the unscaled path because imageWithContentsOfFile: gets the right version for us
			image = [UIImage imageWithContentsOfFile:imagePath];
#else
			//TODO: load image from disk for mac os
#endif
			if (image) {
				[self dispatchCompletionHandlersForKey:key withImage:image error:nil];
			}
			// begin downloading it if noone else is
			else if ([self beginDownload:key]) {
				downloadHandler_(key,^(id downloadedImage, NSError *downloadError){
					if (downloadedImage && downloadError == nil) {
#if TARGET_OS_IPHONE
						if (scale > 1) {
							CGImageRef cgImage = [(UIImage *)downloadedImage CGImage];
							downloadedImage = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];
						}
#else
						//TODO: will Mac OS support @2x?
#endif
						[self storeImage:downloadedImage forKey:key];
						[self dispatchCompletionHandlersForKey:key withImage:downloadedImage error:nil];
					} else {
						[self dispatchCompletionHandlersForKey:key withImage:nil error:downloadError];
					}
					[currentDownloads_ removeObject:key];
				});
			}
		}
	});
}

- (void) cancelFetchForURL:(id)URLOrString {
	if (cancelationHandler_) {
		cancelationHandler_(URLOrString);
	}
}

- (void) removeImageForURL:(id)URLOrString {
	FLog(@"removeImageForURL: %@",URLOrString);
	NSURL *key = [self keyForKeyObject:URLOrString];
	dispatch_async(cacheQueue_, ^{
		[cache_ removeObjectForKey:key];
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

- (void) addHandler:(FSQImageCacheCompletionHandler)handler forKey:(NSURL *)key {
	NSMutableSet *handlersForKey = [completionHandlersByKey_ objectForKey:key];
	if (handlersForKey == nil) {
		handlersForKey = [NSMutableSet new];
		[completionHandlersByKey_ setObject:handlersForKey forKey:key];
	}
	[handlersForKey addObject:[handler copy]];
}

- (void) dispatchCompletionHandlersForKey:(NSURL *)key withImage:(id)image error:(NSError *)error {
	NSSet *handlers = [completionHandlersByKey_ objectForKey:key];
	for (FSQImageCacheCompletionHandler handler in handlers) {
		dispatch_async(dispatch_get_main_queue(), ^{
			handler(image,error);
		});
	}
	[completionHandlersByKey_ removeObjectForKey:key];
}

- (BOOL) beginDownload:(NSURL *)key {
	FSQAssert(downloadHandler_ != nil, @"downloadHandler cannot be nil!");
	if (downloadHandler_ == nil) {
		return NO;
	}
	if (NO == [currentDownloads_ containsObject:key]) {
		[currentDownloads_ addObject:key];
		return YES;
	}
	return NO;
}
		
- (void) storeImage:(id)image forKey:(NSURL *)key {
//	FLog(@"storeImage:forURL: %@",key);
	
	// all cache access is piped through our serial queue so there are no concurrency issues
	dispatch_async(cacheQueue_, ^{
		
		// trim memory cache if over size
#if TARGET_OS_IPHONE
		NSData *imageData = UIImagePNGRepresentation(image);
#else
		NSData *imageData = nil; //TODO: get image data for mac os
#endif
		NSUInteger imageSize = [imageData length];
		
		__block NSUInteger newMemoryUsage = currentMemoryUsage_ + imageSize;
		if (memoryCapacity_ != 0 && newMemoryUsage > memoryCapacity_) {
			FLog(@"Memory capacity (%u) exceeded, purging cache",currentMemoryUsage_);
			
			NSArray *sortedCacheKeys = [cache_ keysSortedByValueUsingComparator:^NSComparisonResult(FSQImageCacheEntry *obj1, FSQImageCacheEntry *obj2) {
				return [obj2.lastAccessDate compare:obj1.lastAccessDate]; // Descending by date
			}];
			
			[sortedCacheKeys enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id cacheKey, NSUInteger idx, BOOL *stop) {
				id cachedImage FSQ_MAYBE_UNUSED = [[cache_ objectForKey:cacheKey] image];
#if TARGET_OS_IPHONE
				NSData *entryData = UIImagePNGRepresentation(cachedImage);
#else
				NSData *entryData = nil; //TODO: get image data for mac os
#endif				
				[cache_ removeObjectForKey:cacheKey];
				newMemoryUsage -= [entryData length];
				*stop = newMemoryUsage < memoryCapacity_;
			}];
		}
		
		// store in memory cache
		[cache_ setObject:[FSQImageCacheEntry withImage:image] forKey:key];
		currentMemoryUsage_ = newMemoryUsage;
		
		// trim disk cache if over size
		__block NSUInteger newDiskUsage = currentDiskUsage_ + imageSize;
		if (diskCapacity_ != 0 && newDiskUsage > diskCapacity_) {
			FLog(@"Disk capacity (%u) exceeded, purging cache",currentDiskUsage_);
			
			NSArray *sortedFileList = [fileList_ sortedArrayUsingComparator:^NSComparisonResult(FSQImageCacheEntry *obj1, FSQImageCacheEntry *obj2) {
				return [obj2.lastAccessDate compare:obj1.lastAccessDate]; // Descending by date
			}];
			
			[sortedFileList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id file, NSUInteger idx, BOOL *stop) {
				id fileSize;
				NSError *error = nil;
				if ([file getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
					NSUInteger bytes = [fileSize unsignedIntegerValue];
					NSFileManager *fm = [NSFileManager new];
					if ([fm removeItemAtURL:file error:&error]) {
						[fileList_ removeObject:file];
						newMemoryUsage -= bytes;
					};
				}
				FSQAssert(error == nil, @"Couldn't get file size");
				*stop = newDiskUsage < diskCapacity_;
			}];
			
		}
		
		// store in disk cache
		NSError *writeError = nil;
		if (NO == [imageData writeToFile:[self cachePathForKey:key] options:NSDataWritingAtomic error:&writeError]) {
			FLogError(writeError, @"Could not write image to disk");
		}
	});
}

		 
// ========================================================================== //

#pragma mark - Notifications


#if TARGET_OS_IPHONE

- (void) didReceiveMemoryWarning:(NSNotification *)notification {
	dispatch_async(cacheQueue_, ^{
		[cache_ removeAllObjects];
	});
}

#endif		 

@end




