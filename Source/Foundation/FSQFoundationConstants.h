//
//  FSQFoundationConstants.h
//  FivesquareKit
//
//  Created by John Clayton on 2/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kFSQFoundationErrorDomain;

extern NSString *kFSQMapperErrorInfoKeyFailingSourceKeyPath;
extern NSString *kFSQMapperErrorInfoKeyFailingDestinationKeyPath;

typedef void (^FSQImageCacheCompletionHandler)(id image, NSError *error);


#define kFSQMapperErrorCodeMappingFailed -1
