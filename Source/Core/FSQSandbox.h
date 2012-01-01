//
//  FSQSandbox.h
//  FivesquareKit
//
//  Created by John Clayton on 1/29/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSQSandbox : NSObject {

}

+ (NSString *) documentsDirectory;
+ (NSString *) applicationSupportDirectory;
+ (NSString *) cachesDirectory;

+ (BOOL) createDocumentsDirectory;
+ (BOOL) createApplicationSupportDirectory;
+ (BOOL) createCachesDirectory;

/** Return the string representing any directory in the user search domain given its constant, e.g.,  NSCachesDirectory. */
+ (NSString *) directoryInUserSearchPath:(NSUInteger)directoryIdentifier;

/** Create any direcotry in the user domain given the directory constant, e.g.,  NSCachesDirectory.  */
+ (BOOL) createDirectoryInUserSearchPath:(NSUInteger)directoryIdentifier error:(NSError **)error;

@end
