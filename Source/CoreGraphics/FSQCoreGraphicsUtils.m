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
  int bytesPerPixel, 
  int bitsPerComponent,
  CGImageAlphaInfo alphaInformation                                       
) {        
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (rect.size.width * bytesPerPixel);
    bitmapByteCount     = (bitmapBytesPerRow * rect.size.height);
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL)  {
        NSLog(@"Couldn't allocate memory for bitmap context");
        return NULL;
    }
    context = CGBitmapContextCreate(bitmapData,
                                    rect.size.width,
                                    rect.size.height,
                                    bitsPerComponent,
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    alphaInformation);
    if (context== NULL) {
        free (bitmapData);
        NSLog(@"Could not create bitmap context");
        return NULL;
    }    
    return context;
}

float radiansForDegrees(float degrees) {
    return degrees * (M_PI / 180.0);
}
