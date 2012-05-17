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

extern NSString *kFSQImageCacheURLWithOptionalScaleExpression;

enum {
	kFSQImageCacheURLComponentBase = 1
	, kFSQImageCacheURLComponentFilename = 2
	, kFSQImageCacheURLComponentScaleFactor = 3
	, kFSQImageCacheURLComponentScale = 4
	, kFSQImageCacheURLComponentExtension = 5
};


#define kFSQMapperErrorCodeMappingFailed -1
