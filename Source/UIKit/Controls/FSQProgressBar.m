//
//  FSQProgressBar.m
//  FivesquareKit
//
//  Created by John Clayton on 5/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQProgressBar.h"

#import <QuartzCore/QuartzCore.h>

#define kFSQProgressBarTrackPadding 1

@interface FSQProgressBar ()
@property (nonatomic, weak) CAGradientLayer *trackLayer;
@property (nonatomic, weak) CAGradientLayer *tintLayer;
- (void) initialize;
@end

@implementation FSQProgressBar

// ========================================================================== //

#pragma mark - Properties



@synthesize progress=progress_;
@synthesize progressTrackGradientComponents=progressTrackGradientComponents_;
@synthesize progressTintGradientComponents=progressTintGradientComponents_;

- (void) setProgress:(CGFloat)progress {
	if (progress_ != progress) {
		progress_ = progress;
		[self setNeedsLayout];
	}
}

- (void) setProgressTrackGradientComponents:(NSArray *)progressTrackGradientComponents {
	if (progressTrackGradientComponents_ != progressTrackGradientComponents) {
		progressTrackGradientComponents_ = progressTrackGradientComponents;
		trackLayer_.colors = [progressTrackGradientComponents_ valueForKey:@"color"];
		trackLayer_.locations = [progressTrackGradientComponents_ valueForKey:@"location"];
	}
}

- (void) setProgressTintGradientComponents:(NSArray *)progressTintGradientComponents {
	if (progressTintGradientComponents_ != progressTintGradientComponents) {
		progressTintGradientComponents_ = progressTintGradientComponents;
		tintLayer_.colors = [progressTintGradientComponents_ valueForKey:@"color"];
		tintLayer_.locations = [progressTintGradientComponents_ valueForKey:@"location"];
	}
}


// Private

@synthesize trackLayer=trackLayer_;
@synthesize tintLayer=tintLayer_;



// ========================================================================== //

#pragma mark - Object



- (void) initialize {
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:.35];
	
	CAGradientLayer *trackLayer = [[CAGradientLayer alloc] init];
	[self.layer addSublayer:trackLayer];
	trackLayer_ = trackLayer;

	CAGradientLayer *tintLayer = [[CAGradientLayer alloc] init];	
	CALayer *tintMask = [[CALayer alloc] init];
	tintMask.backgroundColor = [UIColor blackColor].CGColor;
	tintLayer.mask = tintMask;
	
	[self.layer addSublayer:tintLayer];
	tintLayer_ = tintLayer;

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
		
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	self.layer.cornerRadius  = self.bounds.size.height/2.f;
	
	trackLayer_.frame = self.bounds;
	trackLayer_.cornerRadius = self.layer.cornerRadius;

	CGRect tintFrame = CGRectInset(self.bounds, kFSQProgressBarTrackPadding, kFSQProgressBarTrackPadding);
	tintLayer_.frame = tintFrame;
	
	tintLayer_.cornerRadius = tintFrame.size.height / 2.f;

	[UIView animateWithDuration:0.265 animations:^{
		CGRect tintMaskFrame = tintFrame;
		tintMaskFrame.size.width = tintMaskFrame.size.width*progress_;
		tintLayer_.mask.frame = tintMaskFrame;
	}];

}

@end
