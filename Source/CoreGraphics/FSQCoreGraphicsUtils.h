/*
 *  FSQCoreGraphicsUtils.h
 *  FivesquareKit
 *
 *  Created by John Clayton on 7/15/2008.
 *  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
 *
 */

#include <Foundation/Foundation.h>
#include <QuartzCore/QuartzCore.h>

CGImageRef CreateButtonImage(CGRect rect);
CGImageRef CreateResizedImageInCALayer(
    CGImageRef originalImage, 
    CGRect resizeRect, 
    CFStringRef contentsGravity, 
    CGColorRef backgroundColor, 
    int flip
);
CFDataRef CreateResizedImageDataInCALayer(
    CGImageRef originalImage, 
    CGRect resizeRect, 
    CFStringRef contentsGravity, 
    CGColorRef backgroundColor, 
    int flip
);
CGContextRef CreateBitmapContextAndRenderResizedImageInCALayer(
    CGImageRef originalImage, 
    CGRect resizeRect, 
    CFStringRef contentsGravity, 
    CGColorRef backgroundColor, 
    int flip
);
CGMutablePathRef CreateRoundedRectPath(CGRect rect, CGFloat radius);
CGMutablePathRef CreateRoundedTrianglePath(CGRect rect, CGFloat radius);
CGMutablePathRef CreateRoundedBottomBandPath(CGRect rect, CGFloat radius);
CGContextRef CreateBitmapRenderingContext(
    CGRect rect, 
    CGColorSpaceRef colorSpace, 
    size_t bytesPerPixel, 
    size_t bitsPerComponent, 
    CGImageAlphaInfo alphaInformation
);


float RadiansForDegrees(float degrees);

CGFloat CGPointDistanceFromPoint(CGPoint firstPoint, CGPoint secondPoint);
CGPoint CGPointDeltaPoint(CGPoint firstPoint, CGPoint secondPoint);

CGRect CGRectFlipInBounds(CGRect rect, CGRect bounds);
CGPoint CGPointFlipInBounds(CGPoint point, CGRect bounds);

#if TARGET_OS_IPHONE == 0
CGSize CGSizeFromString(NSString *string);
NSString *NSStringFromCGSize(CGSize size);
#endif