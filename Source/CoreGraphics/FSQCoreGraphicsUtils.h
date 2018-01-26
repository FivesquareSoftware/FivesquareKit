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



CGAffineTransform CGAffineTransformMakeXShear(CGFloat proportion);
CGAffineTransform CGAffineTransformXShear(CGAffineTransform src, CGFloat proportion);
CGAffineTransform CGAffineTransformMakeYShear(CGFloat proportion);
CGAffineTransform CGAffineTransformYShear(CGAffineTransform src, CGFloat proportion);


#define CATransform3DPerspective(t, x, y) (CATransform3DConcat(t, CATransform3DMake(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, 0, 0, 0, 0, 1)))
#define CATransform3DMakePerspective(x, y) (CATransform3DPerspective(CATransform3DIdentity, x, y))

CATransform3D CATransform3DMake(CGFloat m11, CGFloat m12, CGFloat m13, CGFloat m14,
								CGFloat m21, CGFloat m22, CGFloat m23, CGFloat m24,
								CGFloat m31, CGFloat m32, CGFloat m33, CGFloat m34,
								CGFloat m41, CGFloat m42, CGFloat m43, CGFloat m44);


CGSize CGSizeInset(CGSize size, CGFloat dx, CGFloat dy);
