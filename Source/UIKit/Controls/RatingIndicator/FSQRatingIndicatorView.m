//
//  GARatingIndicator.m
//  FivesquareKit
//
//  Created by John Clayton on 11/6/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQRatingIndicatorView.h"

#import "FSQLogging.h"

#define kFSQRatingIndicatorViewMaxSegments 8


@implementation FSQRatingIndicatorView


// ========================================================================== //

#pragma mark -
#pragma mark Properties




- (void) setValue:(NSInteger)newValue {
    if(_value != newValue) {
        if(newValue <= _segments) {
            _value = newValue;
			[self setNeedsDisplay];
			[self.delegate ratingIndicatorValueChanged:self];
        }
    }
}

- (void) setSegments:(NSUInteger)newSegments {
    if(_segments != newSegments) {
        if(newSegments <= kFSQRatingIndicatorViewMaxSegments) {
            _segments = newSegments;
        }
    }
}



// ========================================================================== //

#pragma mark -
#pragma mark Object



- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.offImage = [UIImage imageNamed:@"RatingIndicatorOff.png"];
        self.onImage = [UIImage imageNamed:@"RatingIndicatorOn.png"];
        self.segments = 5;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        self.offImage = [UIImage imageNamed:@"RatingIndicatorOff.png"];
        self.onImage = [UIImage imageNamed:@"RatingIndicatorOn.png"];
        self.segments = 5;
    }
    return self;
}





// ========================================================================== //

#pragma mark -
#pragma mark View


- (void)drawRect:(CGRect)rect {
    CGFloat /*minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect),*/ maxx = CGRectGetMaxX(rect);
//    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    CGFloat segmentWidth = maxx / self.segments;
    CGFloat segmentHeight = rect.size.height;

    CGSize offImageSize = self.offImage.size;
    CGFloat offImageInsetX = (segmentWidth - offImageSize.width) / 2.0;
    CGFloat offImageInsetY = (segmentHeight - offImageSize.height) / 2.0;

    CGSize onImageSize = self.onImage.size;
    CGFloat onImageInsetX = (segmentWidth - onImageSize.width) / 2.0;
    CGFloat onImageInsetY = (segmentHeight - onImageSize.height) / 2.0;

    CGFloat segX = 0.0;
    CGFloat segY = 0.0;
    for (int i = 1; i <= self.segments; i++) {
        //CGRect segmentRect = CGRectMake(segX, segY, segmentWidth, segmentHeight);
        if(i <= self.value) {
            [self.onImage drawAtPoint:CGPointMake(segX+onImageInsetX, segY+onImageInsetY)];
        } else {
            [self.offImage drawAtPoint:CGPointMake(segX+offImageInsetX, segY+offImageInsetY)];
        }
        segX += segmentWidth;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	FLog(@"Rating indicator touches canceled");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];

	CGPoint location = [touch locationInView:self];
	CGFloat segment = self.segments * (location.x / self.frame.size.width);

    int newValue = rintf(segment);
    [self setValue:newValue];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView:self];
	CGFloat segment = self.segments * (location.x / self.frame.size.width);
	
    int newValue = rintf(segment);
    [self setValue:	newValue];
}


@end
