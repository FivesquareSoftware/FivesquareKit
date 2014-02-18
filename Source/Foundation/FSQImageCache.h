//
//  FSQImageCache.h
//  FivesquareKit
//
//  Created by John Clayton on 1/17/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

#import "FSQFoundationConstants.h"

typedef NS_ENUM(NSInteger, FSQImageCacheMemoryLimit) {
	FSQImageCacheMemoryLimitNotAllowed = -1,
	FSQImageCacheMemoryLimitNone = 0
};

@interface FSQImageCache : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic) BOOL diskCacheIsVolatile; // When YES, disk cache is placed in a location that the system is allowed to purge. NO by default.
@property (nonatomic, strong, readonly) NSString *diskPath; ///< On iOS a subdirectory in the caches directory, on Mac OS a full path
@property (nonatomic) NSInteger memoryCapacity;
@property (nonatomic, readonly) BOOL usingMemoryCache;
@property (nonatomic) NSString *storageTypeIdentifier; //kUTTypeJPEG or kUTTypePNG, Default is kUTTypeJPEG;

- (id)initWithMemoryCapacity:(NSInteger)memoryCapacity diskPath:(NSString *)diskPath;

- (id) addImage:(id)image;
- (void) setImage:(id)image forKey:(id)key;

- (id) imageForKey:(id)key;
- (id) imageForKey:(id)key scale:(CGFloat)scale;
- (void) getImageForKey:(id)key completion:(FSQImageCacheCompletionHandler)completion;
- (void) getImageForKey:(id)key scale:(CGFloat)scale completion:(FSQImageCacheCompletionHandler)completion;

- (void) removeImageForKey:(id)key removeOnDisk:(BOOL)removeOnDisk;
- (void) removeAllImagesIncludingDisk:(BOOL)removeOnDisk;

@end
