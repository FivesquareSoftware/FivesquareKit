//
//  UIImage+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 11/18/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "UIImage+FSQUIKit.h"


#define ImgLog(frmt,...) NSLog(frmt, ##__VA_ARGS__)

@implementation UIImage (FSQUIKit)

- (UIImage *) imageSizedToFit:(CGSize)fitSize scale:(CGFloat)scale contentMode:(UIViewContentMode)contentMode {

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


	UIGraphicsBeginImageContext(imageSize);

	CGRect imageFrame = CGRectZero;
	imageFrame.size = imageSize;

	if (contentMode == UIViewContentModeScaleAspectFill) {
		CGPoint imageOrigin = CGPointMake((scaledFitSize.width/2.)-(imageSize.width/2.), (scaledFitSize.height/2.)-(imageSize.height/2.));
		imageFrame.origin = imageOrigin;
	}

	[image drawInRect:imageFrame];

	UIImage *rawImage = UIGraphicsGetImageFromCurrentImageContext();
	UIImage *resizedImage = [UIImage imageWithCGImage:rawImage.CGImage scale:scale orientation:UIImageOrientationUp];
	rawImage = nil;
	UIGraphicsEndImageContext();


	return resizedImage;
}

@end
