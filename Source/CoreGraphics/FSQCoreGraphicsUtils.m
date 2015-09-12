/*
 *  FSQCoreGraphicsUtils.c
 *  FivesquareKit
 *
 *  Created by John Clayton on 7/15/2008.
 *  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
 *
 */

#include "FSQCoreGraphicsUtils.h"


#define BUTTON_CORNER_RADIUS 6.0

CGImageRef CreateButtonImage(CGRect rect) {
//    CGColorSpaceRef contextColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorSpaceRef contextColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CreateBitmapRenderingContext(rect, contextColorSpace, 32, 8, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(contextColorSpace);
    
    CGImageRef renderedImage;
    
    // Clip the context
    CGRect clipRect = rect;
    CGMutablePathRef clipPath = CreateRoundedRectPath(clipRect, BUTTON_CORNER_RADIUS);
    CGContextAddPath(context, clipPath);
    CGContextClip(context);
	CGPathRelease(clipPath);
    
    // draw the gradient
    CGGradientRef buttonGradient;
    CGColorSpaceRef buttonColorspace;
    size_t num_locations = 4;
    CGFloat locations[4] = { 0.0, 0.48, 0.52, 1.0 };
    CGFloat components[16] = { 
        74.0/255.0, 108.0/255.0, 155.0/255.0, 1.0,
        71.0/255.0, 105.0/255.0, 153.0/255.0, 1.0,
        88.0/255.0, 119.0/255.0, 162.0/255.0, 1.0,
        142.0/255.0, 164.0/255.0, 193.0/255.0, 1.0
    };
    
//    buttonColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    buttonColorspace = CGColorSpaceCreateDeviceRGB();
    buttonGradient = CGGradientCreateWithColorComponents(buttonColorspace, components,locations, num_locations);
	CGColorSpaceRelease(buttonColorspace);
    CGPoint gStartPoint, gEndPoint;
    gStartPoint.x = rect.size.width / 2.0;
    gStartPoint.y = 0.0;
    gEndPoint.x = rect.size.width / 2.0;
    gEndPoint.y = rect.size.height;
    CGContextDrawLinearGradient (context, buttonGradient, gStartPoint, gEndPoint, 0);
	CGGradientRelease(buttonGradient);
    
    // Black border
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGMutablePathRef blackBorderPath = CreateRoundedRectPath(CGRectMake(rect.origin.x, rect.origin.y + 1.0, rect.size.width, rect.size.height - 1.0), BUTTON_CORNER_RADIUS);
    CGContextAddPath(context, blackBorderPath);
    CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(blackBorderPath);
    
    // White border
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGMutablePathRef whiteBorderPath = CreateRoundedRectPath(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - 1.0), BUTTON_CORNER_RADIUS);
    CGContextAddPath(context, whiteBorderPath);
    CGContextDrawPath(context, kCGPathStroke);
	CGPathRelease(whiteBorderPath);
    
    renderedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return renderedImage;
}


// You own the image
CGImageRef CreateResizedImageInCALayer(
    CGImageRef originalImage, 
    CGRect resizeRect,      
    CFStringRef contentsGravity,
    CGColorRef backgroundColor,
    int flip
) {
    CGContextRef context = CreateBitmapContextAndRenderResizedImageInCALayer(originalImage,resizeRect,contentsGravity,backgroundColor,flip);        
    CGImageRef renderedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return renderedImage;
}

// Returns a statically allocated CFData object with the resized image data
CFDataRef CreateResizedImageDataInCALayer(
    CGImageRef originalImage, 
    CGRect resizeRect,      
    CFStringRef contentsGravity,
    CGColorRef backgroundColor,
    int flip
) {
    CGContextRef context = CreateBitmapContextAndRenderResizedImageInCALayer(originalImage,resizeRect,contentsGravity,backgroundColor,flip);   
    void * data = CGBitmapContextGetData(context);

    // we need the size of the data
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    bitmapBytesPerRow   = (resizeRect.size.width * 32);
    bitmapByteCount     = (bitmapBytesPerRow * resizeRect.size.height);
    CFDataRef imgData = CFDataCreate(NULL, data, bitmapByteCount);
    CGContextRelease(context);
    free(data);
    return imgData;
}

// You own the context
CGContextRef CreateBitmapContextAndRenderResizedImageInCALayer(
    CGImageRef originalImage, 
    CGRect resizeRect,      
    CFStringRef contentsGravity,
    CGColorRef backgroundColor,
    int flip
) {
//    CGColorSpaceRef contextColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorSpaceRef contextColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CreateBitmapRenderingContext(resizeRect, contextColorSpace, 32, 8, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(contextColorSpace);
    
    if(flip) {
        CGContextTranslateCTM(context, 0.0, resizeRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    
    CALayer *renderingLayer = [[CALayer alloc] init];
    renderingLayer.frame = resizeRect;
    renderingLayer.contentsGravity = (__bridge NSString*)contentsGravity;
    renderingLayer.backgroundColor = backgroundColor;
    renderingLayer.contents = (__bridge id)originalImage;
    [renderingLayer renderInContext:context];
    return context;
}

CGMutablePathRef CreateRoundedRectPath(CGRect rect, CGFloat radius) {
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGMutablePathRef rectPath = CGPathCreateMutable();    
    CGPathMoveToPoint(rectPath, NULL, minx, midy);
    CGPathAddArcToPoint(rectPath, NULL, minx, miny, midx, miny, radius);
    CGPathAddArcToPoint(rectPath, NULL, maxx, miny, maxx, midy, radius);
    CGPathAddArcToPoint(rectPath, NULL, maxx, maxy, midx, maxy, radius);
    CGPathAddArcToPoint(rectPath, NULL, minx, maxy, minx, midy, radius); 
    CGPathCloseSubpath(rectPath);
    return rectPath;
}

CGMutablePathRef CreateRoundedTrianglePath(CGRect rect, CGFloat radius) {
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect);
    
    CGMutablePathRef trianglePath = CGPathCreateMutable();    
    CGPathMoveToPoint(trianglePath, NULL, minx, midy);
    CGPathAddArcToPoint(trianglePath, NULL, minx, miny, midx, miny, radius);
    CGPathAddLineToPoint(trianglePath, NULL, midx, miny);
    CGPathAddLineToPoint(trianglePath, NULL, minx, midy);
    CGPathCloseSubpath(trianglePath);
    return trianglePath;
}

CGMutablePathRef CreateRoundedBottomBandPath(CGRect rect, CGFloat radius) {
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat maxy = CGRectGetMaxY(rect);
    
    CGFloat starty = rect.size.height * 0.85;

    CGMutablePathRef bandPath = CGPathCreateMutable();    
    CGPathMoveToPoint(bandPath, NULL, minx, starty);
    CGPathAddArcToPoint(bandPath, NULL, minx, maxy, midx, maxy, radius);
    CGPathAddArcToPoint(bandPath, NULL, maxx, maxy, maxx, starty, radius);
    CGPathAddLineToPoint(bandPath, NULL, maxx, starty);
    CGPathAddLineToPoint(bandPath, NULL, minx, starty);
//    CGPathAddArcToPoint(bandPath, NULL, maxx, maxy, midx, maxy, radius);
//    CGPathAddArcToPoint(bandPath, NULL, minx, maxy, minx, midy, radius); 
    CGPathCloseSubpath(bandPath);
    return bandPath;
}

// Creates a bitmap context you can draw in
CGContextRef CreateBitmapRenderingContext(
  CGRect rect, 
  CGColorSpaceRef colorSpace, 
  size_t bytesPerPixel, 
  size_t bitsPerComponent,
  CGImageAlphaInfo alphaInformation                                       
) {        
    CGContextRef    context = NULL;
    size_t             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (rect.size.width * bytesPerPixel);
    context = CGBitmapContextCreate(NULL,
                                    rect.size.width,
                                    rect.size.height,
                                    bitsPerComponent,
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    alphaInformation);
    if (context== NULL) {
        NSLog(@"Could not create bitmap context");
        return NULL;
    }    
    return context;
}

float RadiansForDegrees(float degrees) {
    return degrees * (M_PI / 180.0);
}

CGFloat CGPointDistanceFromPoint(CGPoint firstPoint, CGPoint secondPoint) {
	CGFloat a = firstPoint.x-secondPoint.x;
	CGFloat b = firstPoint.y-secondPoint.y;
	
	CGFloat c = sqrtf(powf(a,2)+powf(b,2));
	return fabs(c);
}

CGPoint CGPointDeltaPoint(CGPoint firstPoint, CGPoint secondPoint) {
	CGFloat dX = firstPoint.x-secondPoint.x;
	CGFloat dY = firstPoint.y-secondPoint.y;
	
	CGPoint velocity = CGPointMake(dX, dY);
	return velocity;
}

CGRect CGRectFlipInBounds(CGRect rect, CGRect bounds) {
	rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(bounds)));
	rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1.f, -1.f));
	return rect;

}

CGPoint CGPointFlipInBounds(CGPoint point, CGRect bounds) {
	point = CGPointApplyAffineTransform(point, CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(bounds)));
	point = CGPointApplyAffineTransform(point, CGAffineTransformMakeScale(1.f, -1.f));
	return point;
}

#if TARGET_OS_IPHONE == 0
CGSize CGSizeFromString(NSString *string) {
    return NSSizeFromString(string);
}
NSString *NSStringFromCGSize(CGSize size) {
    return NSStringFromSize(size);
}
#endif

CGAffineTransform CGAffineTransformMakeXShear(CGFloat proportion)
{
	return CGAffineTransformMake(1.0, 0.0, proportion, 1.0, 0.0, 0.0);
}
CGAffineTransform CGAffineTransformXShear(CGAffineTransform src, CGFloat proportion)
{
	return CGAffineTransformConcat(src, CGAffineTransformMakeXShear(proportion));
}
CGAffineTransform CGAffineTransformMakeYShear(CGFloat proportion)
{
	return CGAffineTransformMake(1.0, proportion, 0.0, 1.0, 0.0, 0.0);
}
CGAffineTransform CGAffineTransformYShear(CGAffineTransform src, CGFloat proportion)
{
	return CGAffineTransformConcat(src, CGAffineTransformMakeYShear(proportion));
}

CATransform3D CATransform3DMake(CGFloat m11, CGFloat m12, CGFloat m13, CGFloat m14,
				  CGFloat m21, CGFloat m22, CGFloat m23, CGFloat m24,
				  CGFloat m31, CGFloat m32, CGFloat m33, CGFloat m34,
				  CGFloat m41, CGFloat m42, CGFloat m43, CGFloat m44)
{
	CATransform3D t;
	t.m11 = m11; t.m12 = m12; t.m13 = m13; t.m14 = m14;
	t.m21 = m21; t.m22 = m22; t.m23 = m23; t.m24 = m24;
	t.m31 = m31; t.m32 = m32; t.m33 = m33; t.m34 = m34;
	t.m41 = m41; t.m42 = m42; t.m43 = m43; t.m44 = m44;
	return t;
}

