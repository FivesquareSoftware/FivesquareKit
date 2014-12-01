//
//  FSQImageCache.m
//  FivesquareKit
//
//  Created by John Clayton on 1/17/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQImageCache.h"



#import "FSQSandbox.h"
#import "FSQAsserter.h"
#import "FSQLogging.h"
#import "FSQMacros.h"
#import "NSString+FSQFoundation.h"
#import "NSURL+FSQFoundation.h"
#import "NSDictionary+FSQFoundation.h"
#import "FSQRuntime.h"
#import "UIImage+FSQUIKit.h"

#define kImageCacheScaleNoScale -1.


#define kDebugImageCache DEBUG && 0
#define CacheLog(frmt,...) FLogMarkIf(kDebugImageCache, ([NSString stringWithFormat:@"IMG-CACHE.%@",self.name]) ,frmt, ##__VA_ARGS__)

@interface FSQImage : UIImage
@end

@implementation FSQImage
+ (id) imageWithCGImage:(CGImageRef)imageRef {
	__autoreleasing FSQImage *img =  [[super alloc] initWithCGImage:imageRef];
	FLogMarkIf(kDebugImageCache, @"IMG-CACHE",@"initWithCGImage: %@",self);
	return img;
}
+ (id) imageWithContentsOfFile:(NSString *)file {
	__autoreleasing FSQImage *img =  [[super alloc] initWithContentsOfFile:file];
	FLogMarkIf(kDebugImageCache, @"IMG-CACHE",@"imageWithContentsOfFile: %@",self);
	return img;
}
+ (id) imageWithData:(NSData *)data {
	__autoreleasing FSQImage *img =  [[super alloc] initWithData:data];
	FLogMarkIf(kDebugImageCache, @"IMG-CACHE",@"imageWithData: %@",self);
	return img;
}
- (void) dealloc {
	FLogMarkIf(kDebugImageCache, @"IMG-CACHE",@"IMG->DEALLOC: %@",self);
}
- (NSString *) description {
	return [NSString stringWithFormat:@"<FSQImage:%p>",self];
}
//- (id)copyWithZone:(NSZone *)zone {
//	return [self copyWithZone:zone];
//}
@end



@interface FSQImageCache () <NSCacheDelegate>

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) dispatch_queue_t cacheQueue;
@property (nonatomic, strong) NSMutableSet *keys;
@property (nonatomic, strong) NSString *cachePath;

@property (nonatomic, strong) id memoryWarningObserver;

@property (nonatomic, strong, readonly) CIContext *coreImageContext;

@end

@implementation FSQImageCache

// ========================================================================== //

#pragma mark - Properties

- (void) setName:(NSString *)name {
	if (_name != name) {
		_name = name;
		_cache.name = _name;
	}
}

- (void) setMemoryCapacity:(NSInteger)memoryCapacity {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),@(memoryCapacity));
	if (_memoryCapacity != memoryCapacity) {
		_memoryCapacity = memoryCapacity;
		if (_memoryCapacity >= 0) {
			[_cache setTotalCostLimit:(NSUInteger)memoryCapacity];
		}
		_usingMemoryCache = _memoryCapacity >= 0;
	}
}

- (NSString *) cachePath {
	if (_cachePath == nil) {
		BOOL created;
		NSError *error = nil;
#if TARGET_OS_IPHONE
		NSString *baseDirectory = _diskCacheIsVolatile ? [FSQSandbox cachesDirectory] : [FSQSandbox applicationSupportDirectory];
		_cachePath = [baseDirectory stringByAppendingPathComponent:_diskPath];
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

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ name=%@ diskPath=%@ memoryCapacity=%@",[super description], _name, _diskPath, @(_memoryCapacity)];
}

@synthesize coreImageContext = _coreImageContext;
- (CIContext *) coreImageContext {
	static dispatch_once_t coreImageContextInitToken;
	dispatch_once(&coreImageContextInitToken, ^{
		_coreImageContext = [CIContext contextWithOptions:nil];
	});
	return _coreImageContext;
}


// ========================================================================== //

#pragma mark - Object

- (void)dealloc
{
	if (_memoryWarningObserver) {
		[[NSNotificationCenter defaultCenter] removeObserver:_memoryWarningObserver];
	}
}

- (id) init {
	return [self initWithMemoryCapacity:0 diskPath:[[NSUUID UUID] UUIDString]];
}

- (id)initWithMemoryCapacity:(NSInteger)memoryCapacity diskPath:(NSString *)diskPath {
	self = [super init];
	if (self) {
		_name = [[NSUUID UUID] UUIDString];
		_diskCacheIsVolatile = NO;
		_storageTypeIdentifier = (NSString *)kUTTypeJPEG;
		_diskPath = diskPath;
		_cache = [[NSCache alloc] init];
		_cacheQueue = dispatch_queue_create([[NSString stringWithFormat:@"com.fivesquaresoftware.FSQImageCache.%p.cacheQueue",self] UTF8String], DISPATCH_QUEUE_CONCURRENT);
		_keys = [NSMutableSet new];
		_compressionQuality = .8;
		_targetSize = CGSizeZero;
		_contentMode = UIViewContentModeScaleAspectFill;

		self.memoryCapacity = memoryCapacity;
		
#if TARGET_OS_IPHONE
		FSQWeakSelf(self_);
		self.memoryWarningObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			CacheLog(@"!!! * OUT OF MEMORY, PURGING %@ * !!!",self_);
			[self_.cache removeAllObjects];
		}];
#endif

		
		dispatch_barrier_async(_cacheQueue, ^{
			NSFileManager *fm = [NSFileManager new];
			NSError *error = nil;
			
			NSArray *files = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.cachePath]
							   includingPropertiesForKeys:@[NSURLContentAccessDateKey,NSURLFileSizeKey]
												  options:NSDirectoryEnumerationSkipsHiddenFiles
													error:&error];
			if (error) {
				FLogError(error, @"Could not build existing key list!");
			}
			else {
				for (NSURL *file in files) {
					[_keys addObject:[[file lastPathComponent] stringByDeletingPathExtension]];
				}
			}
		});
	}
	return self;
}



// ========================================================================== //

#pragma mark - Image Cache




- (id) addImage:(id)image {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),image);
	id key = [self newKeyForImage:image];
	[self setImage:image forKey:key];
	return key;
}

- (void) setImage:(id)image forKey:(id)key {
	CacheLog(@"setImage:%@ forKey:%@",image,key);
	dispatch_barrier_sync(_cacheQueue, ^{
		[self _storeImage:image forKey:key];
	});
}

- (id) imageForKey:(id)key {
	return [self imageForKey:key scale:kImageCacheScaleNoScale];
}

- (id) imageForKey:(id)key scale:(CGFloat)scaleOverride {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),key);
	__block id fetchedImage = nil;
	dispatch_sync(_cacheQueue, ^{
		fetchedImage = [self _getImageForKey:key scale:scaleOverride];
	});
	return fetchedImage;
}

- (void) getImageForKey:(id)key completion:(FSQImageCacheCompletionHandler)completion {
	[self getImageForKey:key scale:kImageCacheScaleNoScale completion:completion];
}

- (void) getImageForKey:(id)key scale:(CGFloat)scale completion:(FSQImageCacheCompletionHandler)completion {
	CacheLog(@"getImageForKey:%@ scale:%@",key,@(scale));
	__block id image = nil;
	dispatch_async(_cacheQueue, ^{
		image = [self _getImageForKey:key scale:scale];
		if (completion) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(image,nil);
				image = nil;
			});
		}
	});
}

- (NSURL *) fileURLForKey:(id)key {
	return [self fileURLForKey:key scale:kImageCacheScaleNoScale];
}

- (NSURL *) fileURLForKey:(id)key scale:(CGFloat)scaleOverride {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),key);
	__block NSURL *imageURL = nil;
	dispatch_sync(_cacheQueue, ^{
		CacheLog(@"%@",NSStringFromSelector(_cmd));
		CGFloat scale = 1;
		if (scaleOverride > 0.) {
			scale = scaleOverride;
		}
		else {
#if TARGET_OS_IPHONE
			scale = [[UIScreen mainScreen] scale];
#endif
		}

		NSString *storageKey = [self storageKeyForKey:key scale:scale];
		NSString *imagePath = [self cachePathForStorageKey:storageKey];
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:imagePath]) {
			imageURL = [NSURL fileURLWithPath:imagePath];
		}
	});
	return imageURL;
}

- (NSDate *) modificationDateForKey:(id)key {
	return [self modificationDateForKey:key scale:kImageCacheScaleNoScale];
}

- (NSDate *) modificationDateForKey:(id)key scale:(CGFloat)scaleOverride {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),key);
	__block NSDate *modificationDate = nil;
	dispatch_sync(_cacheQueue, ^{
		CacheLog(@"%@",NSStringFromSelector(_cmd));
		CGFloat scale = 1;
		if (scaleOverride > 0.) {
			scale = scaleOverride;
		}
		else {
#if TARGET_OS_IPHONE
			scale = [[UIScreen mainScreen] scale];
#endif
		}

		NSString *storageKey = [self storageKeyForKey:key scale:scale];
		NSString *imagePath = [self cachePathForStorageKey:storageKey];
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:imagePath]) {
			NSError *attributesError = nil;
			NSDictionary *attributes = [fm attributesOfItemAtPath:imagePath error:&attributesError];
			if (attributesError) {
				FLogError(attributesError, @"Failed to get file attributes for image at path: %@",imagePath);
			}
			if (attributes) {
				modificationDate = attributes[NSFileModificationDate];
			}
		}
	});
	return modificationDate;
}

- (BOOL) imageForKey:(id)key needsUpdate:(NSDate *)date {
	return [self imageForKey:key scale:kImageCacheScaleNoScale needsUpdate:date];
}

- (BOOL) imageForKey:(id)key scale:(CGFloat)scaleOverride needsUpdate:(NSDate *)date {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),key);
	NSParameterAssert(date);
	NSDate *modificationDate = [self modificationDateForKey:key scale:scaleOverride];
	if (modificationDate) {
		return [modificationDate compare:date] == NSOrderedAscending;
	}
	return YES;
}

- (void) removeImageForKey:(id)key removeOnDisk:(BOOL)removeOnDisk {
	[self removeImageForKey:key removeOnDisk:removeOnDisk scale:kImageCacheScaleNoScale];
}

- (void) removeImageForKey:(id)key removeOnDisk:(BOOL)removeOnDisk scale:(CGFloat)scale {
	CacheLog(@"removeImageForKey:%@ removeOnDisk:%@",key,@(removeOnDisk));
	dispatch_barrier_async(_cacheQueue, ^{
		@autoreleasepool {
			[self _removeImageForKey:key removeOnDisk:removeOnDisk scale:scale];
		}
	});
}

- (void) removeAllImagesIncludingDisk:(BOOL)removeOnDisk {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),@(removeOnDisk));
	dispatch_barrier_async(_cacheQueue, ^{
		@autoreleasepool {
			for (id key in _keys) {
				[self removeImageForKey:key removeOnDisk:removeOnDisk];
			}
		}
	});
}


// ========================================================================== //

#pragma mark - Helpers


- (id) storageKeyForKey:(id)key scale:(CGFloat)scale {
	CacheLog(@"%@%@",NSStringFromSelector(_cmd),key);
	NSString *keyString;
	NSString *storageKey;
	if ([key isKindOfClass:[NSString class]]) {
		keyString = key;
	}
	else {
		keyString = [key description];
	}
	keyString = [keyString stringByDeletingPathExtension];
	keyString = [keyString stringByDeletingScaleModifier];
	

	if (scale != 1) {
		storageKey = [NSString stringWithFormat:@"%@@%@x.%@",keyString,@(scale),[self storageExtensionForStorageType]];
	}
	else {
		storageKey = [NSString stringWithFormat:@"%@.%@",keyString,[self storageExtensionForStorageType]];
	}

	
	CacheLog(@"<= %@",storageKey);
	return storageKey;
}

- (id) newKeyForImage:(id)image {
	NSString *key = [[NSUUID UUID] UUIDString];
	return key;
}

- (NSString *) cachePathForStorageKey:(NSString *)storageKey {
	NSString *cachePath = [self.cachePath stringByAppendingPathComponent:storageKey];
	return cachePath;
}

- (NSString *) storageExtensionForStorageType {
	NSString *extension = @"";
	if ([_storageTypeIdentifier isEqualToString:(NSString *)kUTTypeJPEG]) {
		extension = @"jpg";
	}
	else if ([_storageTypeIdentifier isEqualToString:(NSString *)kUTTypePNG]) {
		extension = @"png";
	}
	return extension;
}


// ========================================================================== //

#pragma mark - Cache Delegate


- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
	CacheLog(@"** EVICTING OBJECT ** : %@",obj);
}






// ========================================================================== //

#pragma mark - Model Access - Must run on cache Q


- (id) _getImageForKey:(id)key scale:(CGFloat)scaleOverride {
	CacheLog(@"%@",NSStringFromSelector(_cmd));
	CGFloat scale = 1;
	if (scaleOverride > 0.) {
		scale = scaleOverride;
	}
	else {
#if TARGET_OS_IPHONE
		scale = [[UIScreen mainScreen] scale];
#endif
	}
	
	NSString *storageKey = [self storageKeyForKey:key scale:scale];
	id image = nil;
	if (_usingMemoryCache) {
		CacheLog(@"** Using memory cache");
		image = [_cache objectForKey:storageKey];
	}
	if (nil == image) {
		if (_usingMemoryCache) {
			CacheLog(@"** IMAGE MEMORY FAULT **");
		}
		
		NSString *imagePath = [self cachePathForStorageKey:storageKey];
#if TARGET_OS_IPHONE
		image = [UIImage imageWithContentsOfFile:imagePath];
		CacheLog(@"- [UIImage imageWithContentsOfFile:%@] => %@, size: %@, scale: %@",imagePath,image,NSStringFromCGSize([image size]),@([(UIImage *)image scale]));
#else
//		//TODO: load image from disk for mac os
#endif
		if (nil == image) {
			CacheLog(@"** IMAGE DISK FAULT **");
		}
		if (_usingMemoryCache && image) {
			__block id localImage = image;
			dispatch_barrier_async(_cacheQueue, ^{
				NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
				FSQAssert(imageURL, @"Couldn't get image URL from image path: %@", imagePath);
				NSNumber *fileSize;
				NSUInteger size = 0;
				NSError *error = nil;
				if ([imageURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error]) {
					size = [fileSize unsignedIntegerValue];
				}
				else {
					FLogError(error, @"Failed to get file size for re-inflated image: %@",imageURL);
				}
				[_cache setObject:localImage forKey:storageKey cost:size];
				localImage = nil;
			});
		}
	}
	return image;
}

- (void) _storeImage:(id)image forKey:(NSString *)key {
	CacheLog(@"%@ => %@",NSStringFromSelector(_cmd),key);
	@autoreleasepool {
		CGFloat scale = 1;
#if TARGET_OS_IPHONE
		scale = [(UIImage *)image scale];
#endif
		if (NO == CGSizeEqualToSize(CGSizeZero, _targetSize)) {
#if TARGET_OS_IPHONE
			scale = [[UIScreen mainScreen] scale];
			image = [image imageSizedToFit:_targetSize scale:scale contentMode:_contentMode];
#endif
		}

		id processedImage = nil;
		if (_filter) {
#if TARGET_OS_IPHONE
			CIImage *input = [[CIImage alloc] initWithImage:image];
			[_filter setValue:input forKey:kCIInputImageKey];
			CIImage *output = [_filter valueForKey:kCIOutputImageKey];
			// This has a bug that produces a blank image
//			processedImage = [UIImage imageWithCIImage:output];
			CGImageRef outputCGImage = [self.coreImageContext createCGImage:output fromRect:CGRectMake(0, 0, [image size].width*scale, [image size].height*scale)];
			processedImage = [UIImage imageWithCGImage:outputCGImage scale:scale orientation:UIImageOrientationUp];
#endif
		}
		else {
			processedImage = image;
		}

		NSString *storageKey = [self storageKeyForKey:key scale:scale];
		NSData *imageData = [self _dataForImage:processedImage];
		NSError *writeError = nil;
		if (NO == [imageData writeToFile:[self cachePathForStorageKey:storageKey] options:NSDataWritingAtomic error:&writeError]) {
			FLogError(writeError, @"Could not write image to disk");
		}
		if (_usingMemoryCache) {
			CacheLog(@" ** STORED TO MEMORY CACHE %@ **",_cache.name);
			[_cache setObject:processedImage forKey:storageKey cost:[imageData length]];
		}
		imageData = nil;
		[_keys addObject:storageKey];
	}
}

- (void) _removeImageForKey:(id)key removeOnDisk:(BOOL)removeOnDisk scale:(CGFloat)scaleOverride {
	CacheLog(@"%@ => %@",NSStringFromSelector(_cmd),key);
	CGFloat scale = 1;
	if (scaleOverride > 0.) {
		scale = scaleOverride;
	}
	else {
#if TARGET_OS_IPHONE
		scale = [[UIScreen mainScreen] scale];
#endif
	}
	NSString *storageKey = [self storageKeyForKey:key scale:scale];
	[_cache removeObjectForKey:storageKey]; // let's just always remove it in case memory limits got changed after it went in
	if (removeOnDisk) {
		NSFileManager *fm = [NSFileManager new];
		NSError *error = nil;
		if (NO == [fm removeItemAtPath:[self cachePathForStorageKey:storageKey] error:&error]) {
			FLogError(error, @"Could not remove entry for %@",storageKey);
		};
	}
	[_keys removeObject:storageKey];
}

- (NSData *) _dataForImage:(id)image {
	__autoreleasing NSData *imageData = nil;
#if TARGET_OS_IPHONE
	if ([_storageTypeIdentifier isEqualToString:(NSString *)kUTTypeJPEG]) {
		imageData = UIImageJPEGRepresentation(image, _compressionQuality);
	}
	else if ([_storageTypeIdentifier isEqualToString:(NSString *)kUTTypePNG]) {
		imageData = UIImagePNGRepresentation(image);
	}
#else
	imageData = nil; //TODO: get image data for mac os
#endif
	FSQAssert(imageData, @"Unable to get image data for image! %@", image);

	return imageData;
}


@end
