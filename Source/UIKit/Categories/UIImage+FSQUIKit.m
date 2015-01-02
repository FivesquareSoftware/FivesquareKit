//
//  UIImage+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 11/18/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "UIImage+FSQUIKit.h"


#define kDebugImage DEBUG && 0

#if kDebugImage
	#define ImgLog(frmt,...) NSLog(frmt, ##__VA_ARGS__)
#else
	#define ImgLog(frmt,...)
#endif

@implementation UIImage (FSQUIKit)

- (CGSize) sizeThatFits:(CGSize)fitSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode {

	NSParameterAssert(contentMode == UIViewContentModeScaleAspectFit || contentMode == UIViewContentModeScaleAspectFill);

	UIImage *image = self;

	CGSize rawSize = image.size;
	CGFloat imageAspect = rawSize.width/rawSize.height;
	ImgLog(@"imageAspect:%@",@(imageAspect));


	CGSize scaledFitSize = CGSizeMake(fitSize.width*scale, fitSize.height*scale);
	CGFloat maxFitDimension = scaledFitSize.height >= scaledFitSize.width ? scaledFitSize.height : scaledFitSize.width;
	CGFloat minFitDimension = scaledFitSize.width >= scaledFitSize.height ? scaledFitSize.width : scaledFitSize.height;


	CGSize imageSize;

	if (imageAspect >= 1.) {
		ImgLog(@"Image more wide than tall");
		if (contentMode == UIViewContentModeScaleAspectFill) {
			ImgLog(@"Scaling height to min dimension (aspect fill)");
			CGFloat scaledWidth = scaledFitSize.width*imageAspect;
			imageSize = CGSizeMake(scaledWidth, minFitDimension);
		}
		else if (contentMode == UIViewContentModeScaleAspectFit) {
			ImgLog(@"scaling screen width to max dimension (aspect fit)");
			CGFloat scaledHeight = maxFitDimension/imageAspect;
			ImgLog(@"scaledHeight:%@",@(scaledHeight));
			imageSize = CGSizeMake(maxFitDimension, scaledHeight);
		}
	}
	else {
		ImgLog(@"Image more tall than wide");

		if (contentMode == UIViewContentModeScaleAspectFill) {
			ImgLog(@"Scaling width to min dimension (aspect fill)");
			CGFloat scaledHeight = scaledFitSize.height/imageAspect;
			imageSize = CGSizeMake(minFitDimension, scaledHeight);
		}
		else if (contentMode == UIViewContentModeScaleAspectFit) {
			ImgLog(@"scaling screen height to max dimension (aspect fit)");
			CGFloat scaledWidth = maxFitDimension*imageAspect;
			ImgLog(@"scaledWidth:%@",@(scaledWidth));
			imageSize = CGSizeMake(scaledWidth, maxFitDimension);
		}
	}

	ImgLog(@"imageSize:%@",NSStringFromCGSize(imageSize));
	ImgLog(@"resulting aspect: %@",@(imageSize.width/imageSize.height));

	return imageSize;
}

- (UIImage *) imageSizedToFit:(CGSize)fitSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode {

	UIImage *image = self;

	CGSize scaledFitSize = CGSizeMake(fitSize.width*scale, fitSize.height*scale);
	CGSize scaledImageSize = [self sizeThatFits:fitSize scale:scale contentMode:contentMode];


	CGSize contextSize;
	if (contentMode == UIViewContentModeScaleAspectFill) {
		contextSize = scaledFitSize; // We are going to fill the entire target size
	}
	else { // UIViewContentModeScaleAspectFit
		contextSize = scaledImageSize; // The image will be smaller that the target size in on dimension or equal
	}
	UIGraphicsBeginImageContext(contextSize);

	CGRect renderFrame = CGRectZero;
	renderFrame.size = scaledImageSize;

	if (contentMode == UIViewContentModeScaleAspectFill) {
		CGPoint imageOrigin = CGPointMake((scaledFitSize.width-scaledImageSize.width)/2., (scaledFitSize.height-scaledImageSize.height)/2.);
		renderFrame.origin = imageOrigin;
	}

	CGRect integralRenderFrame = CGRectIntegral(renderFrame);
	[image drawInRect:integralRenderFrame];

	UIImage *rawImage = UIGraphicsGetImageFromCurrentImageContext();
	UIImage *resizedImage = [UIImage imageWithCGImage:rawImage.CGImage scale:scale orientation:UIImageOrientationUp];
	rawImage = nil;
	UIGraphicsEndImageContext();


	return resizedImage;
}

@end
