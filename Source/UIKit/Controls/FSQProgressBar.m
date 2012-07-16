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




- (void) setProgress:(CGFloat)progress {
	if (_progress != progress) {
		_progress = progress;
		[self setNeedsLayout];
	}
}

- (void) setProgressTrackGradientComponents:(NSArray *)progressTrackGradientComponents {
	if (_progressTrackGradientComponents != progressTrackGradientComponents) {
		_progressTrackGradientComponents = progressTrackGradientComponents;
		_trackLayer.colors = [_progressTrackGradientComponents valueForKey:@"color"];
		_trackLayer.locations = [_progressTrackGradientComponents valueForKey:@"location"];
	}
}

- (void) setProgressTintGradientComponents:(NSArray *)progressTintGradientComponents {
	if (_progressTintGradientComponents != progressTintGradientComponents) {
		_progressTintGradientComponents = progressTintGradientComponents;
		_tintLayer.colors = [_progressTintGradientComponents valueForKey:@"color"];
		_tintLayer.locations = [_progressTintGradientComponents valueForKey:@"location"];
	}
}


// Private




// ========================================================================== //

#pragma mark - Object



- (void) initialize {
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:.35];
	
	CAGradientLayer *trackLayer = [[CAGradientLayer alloc] init];
	[self.layer addSublayer:trackLayer];
	_trackLayer = trackLayer;

	CAGradientLayer *tintLayer = [[CAGradientLayer alloc] init];	
	CALayer *tintMask = [[CALayer alloc] init];
	tintMask.backgroundColor = [UIColor blackColor].CGColor;
	tintLayer.mask = tintMask;
	
	[self.layer addSublayer:tintLayer];
	_tintLayer = tintLayer;

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
	
	_trackLayer.frame = self.bounds;
	_trackLayer.cornerRadius = self.layer.cornerRadius;

	CGRect tintFrame = CGRectInset(self.bounds, kFSQProgressBarTrackPadding, kFSQProgressBarTrackPadding);
	_tintLayer.frame = tintFrame;
	
	_tintLayer.cornerRadius = tintFrame.size.height / 2.f;

	[UIView animateWithDuration:0.265 animations:^{
		CGRect tintMaskFrame = tintFrame;
		tintMaskFrame.size.width = tintMaskFrame.size.width*_progress;
		_tintLayer.mask.frame = tintMaskFrame;
	}];

}

@end
