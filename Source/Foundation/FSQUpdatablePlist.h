//
//  FSQUpdatablePlist.h
//  FivesquareKit
//
//  Created by John Clayton on 9/17/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FSQUpdatablePlistCompletionHandler)(id plist, NSError *error);
typedef void (^FSQUpdatablePlistDownloadHandler)(FSQUpdatablePlistCompletionHandler completionBlock);


@interface FSQUpdatablePlist : NSObject


@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSURL *cacheDirectoryURL;

@property (nonatomic, copy) FSQUpdatablePlistDownloadHandler downloadHandler;

- (instancetype)initWithName:(NSString *)name cacheDirectoryURL:(NSURL *)cacheDirectoryURL downloadHandler:(FSQUpdatablePlistDownloadHandler)downloadHandler;

- (id) loadPlist;
- (id) loadPlistAndUpdateWithHandler:(FSQUpdatablePlistCompletionHandler)updateHandler;
- (void) updatePlistWithUpdateHandler:(FSQUpdatablePlistCompletionHandler)updateHandler;

@end
