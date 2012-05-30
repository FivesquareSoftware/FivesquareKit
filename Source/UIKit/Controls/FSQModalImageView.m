//
//  GAZoomedItemImageView.m
//  FivesquareKit
//
//  Created by John Clayton on 8/7/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQModalImageView.h"
#import <QuartzCore/QuartzCore.h>


@implementation FSQModalImageView


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled = YES;
        self.layer.contentsGravity = kCAGravityResizeAspect;
	}
	return self;
}

- (id) initWithImage:(UIImage *)anImage {
	self = [super initWithImage:anImage];
	if (self != nil) {
        self.backgroundColor = [UIColor blackColor];
        self.userInteractionEnabled = YES;
        self.layer.contentsGravity = kCAGravityResizeAspect;
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    NSUInteger numTaps = [touch tapCount];
    if (numTaps == 1) {
        [self handleSingleTap:touch];
    }
}

- (void) handleSingleTap:(UITouch *)touch {

    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[self.superview layer] addAnimation:animation forKey:@"ShrinkingImageView"];
    
    [self removeFromSuperview];
}



@end
