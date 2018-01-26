//
//  FSQUpdatablePlist.m
//  FivesquareKit
//
//  Created by John Clayton on 9/17/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQUpdatablePlist.h"

#import "FSQLogging.h"
#import "NSError+FSQFoundation.h"
#import "FSQAsserter.h"

@interface FSQUpdatablePlist ()
@property (nonatomic, strong, readonly) NSURL *cacheFileURL;

@end

@implementation FSQUpdatablePlist

- (instancetype)initWithName:(NSString *)name cacheDirectoryURL:(NSURL *)cacheDirectoryURL downloadHandler:(FSQUpdatablePlistDownloadHandler)downloadHandler {
	self = [super init];
	if (self) {
		_name = name;
		_cacheDirectoryURL = cacheDirectoryURL;
		_downloadHandler = downloadHandler;
		_cacheFileURL = [[_cacheDirectoryURL URLByAppendingPathComponent:_name] URLByAppendingPathExtension:@"plist"];
		FSQAssert(_cacheFileURL, @"Failed to create cacheFileURL! %@ %@",_cacheDirectoryURL,_name);
		if (nil == _cacheFileURL) {
			self = nil;
		}
	}
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ { name : %@, cacheFile : %@ }",[super description],_name,_cacheFileURL];
}

- (id) loadPlist {

	// If cached version exists, return it
	// If not, return default from bundle after copying to cache
	// Kick off a request to load remote version and fire update handler when done, caching result

	id plist = nil;
	NSError *readError = nil;
	NSData *plistData;
	NSFileManager *fm = [NSFileManager defaultManager];

	@try {
		if ([fm fileExistsAtPath:[_cacheFileURL path]]) {
			plistData = [NSData dataWithContentsOfFile:[_cacheFileURL path]];
			if (plistData) {
				plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:&readError];
				if (readError) {
					FLogError(readError, @"Failed to read plist from cache for %@",self);
				}
			}
		}
		else {
			NSString *bundlePath = [[NSBundle mainBundle] pathForResource:_name ofType:@"plist"];
			if ([fm fileExistsAtPath:bundlePath]) {
				plistData = [NSData dataWithContentsOfFile:bundlePath];
				if (plistData) {
					plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:&readError];
					if (readError) {
						FLogError(readError, @"Failed to read plist from bundle: %@",bundlePath);
					}
					else {
						[plistData writeToURL:_cacheFileURL atomically:YES];
					}
				}
			}
			else {
				FLogWarn(@"No default plist in bundle for %@",self);
			}
		}
	}
	@catch (NSException *exception) {
		FLogError([NSError errorWithException:exception], @"Exception reading plist from bundle or cache");
	}
	return plist;
}

- (id) loadPlistAndUpdateWithHandler:(FSQUpdatablePlistCompletionHandler)updateHandler {
	id plist = [self loadPlist];
	[self updatePlistWithUpdateHandler:updateHandler];
	return plist;
}

- (void) updatePlistWithUpdateHandler:(FSQUpdatablePlistCompletionHandler)updateHandler {
	if (_downloadHandler) {
		_downloadHandler(^(id updatedPlist, NSError *error){
			if (updatedPlist) {
				// write to cache
				NSError *writeError = nil;
				NSData *remotePlistData = [NSPropertyListSerialization dataWithPropertyList:updatedPlist format:NSPropertyListXMLFormat_v1_0 options:0 error:&writeError];
				if (remotePlistData) {
					[remotePlistData writeToURL:_cacheFileURL atomically:YES];
				}
				else {
					if (writeError) {
						FLogError(writeError, @"Could cache remote plist!");
					}
					else {
						FLogWarn(@"Remote plist produced no data!");
					}
				}
			}
			if (updateHandler) {
				dispatch_async(dispatch_get_main_queue(), ^{
					updateHandler(updatedPlist,error);
				});
			}
		});
	}
}

@end
