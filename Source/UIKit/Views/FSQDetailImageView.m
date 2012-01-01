//
//  FSQDetailImageView.m
//  FivesquareKit
//
//  Created by John Clayton on 8/2/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQDetailImageView.h"

#import "FSQCoreGraphicsUtils.h"
#import "FSQModalImageView.h"



@interface FSQDetailImageView()
- (UIImage *) renderedImageinRect:(CGRect)rect;
- (void) zoomImage;
@end


@implementation FSQDetailImageView

// ========================================================================== //

#pragma mark -
#pragma mark Properties



@synthesize image;
@synthesize renderedImage;
@synthesize borderRadius;

@synthesize zoomsImage;
@synthesize editing;


- (void) setImage:(UIImage *)newImage {
	if(image != newImage) {
		image = newImage;
		self.renderedImage = nil;
		[self setNeedsDisplay];
	}
}

- (void)setEditing:(BOOL)newEditing {
	[self setEditing:newEditing animated:NO];
}


// ========================================================================== //

#pragma mark -
#pragma mark Object




- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.borderRadius = 5.0;
		self.zoomsImage = YES;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if(self) {
		self.borderRadius = 5.0;
		self.zoomsImage = YES;
	}
	return self;
}






// ========================================================================== //

#pragma mark - View



- (void)drawRect:(CGRect)rect {
	if(self.renderedImage == nil) {
		self.renderedImage = [self renderedImageinRect:rect];
	}
	[self.renderedImage drawInRect:rect];
}

- (UIImage *) renderedImageinRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPathRef maskingPath = CreateRoundedRectPath(rect, self.borderRadius);
    CGContextAddPath(context, maskingPath);
	CGContextClip(context);
	CGPathRelease(maskingPath);
	
    CALayer *renderingLayer = [[CALayer alloc] init];
    renderingLayer.frame = rect;
    renderingLayer.contentsGravity = kCAGravityResizeAspectFill;
	renderingLayer.cornerRadius = 5.0;
    renderingLayer.contents = (__bridge id)self.image.CGImage;
    [renderingLayer renderInContext:context];
	
	if(self.editing) {
		NSString *editString = NSLocalizedString(@"edit", @"Rounded Image View Edit Label Text");
		
		UIFont *editFont = [UIFont boldSystemFontOfSize:12.0];
		
		CGSize labelSize = [editString sizeWithFont:editFont];
		CGRect labelRect = CGRectMake(0, rect.size.height - labelSize.height, rect.size.width, labelSize.height);	
		
		UIColor *overlayColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.40];
		CGContextSetFillColorWithColor(context, overlayColor.CGColor);
		CGContextFillRect(context, labelRect);

		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		[editString drawInRect:labelRect 
					  withFont:editFont
				 lineBreakMode:UILineBreakModeClip 
					 alignment:UITextAlignmentCenter];
		
	}
	
	UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();
	
	return roundedImage;
}



// ========================================================================== //

#pragma mark - Responder


- (void)setEditing:(BOOL)newEditing animated:(BOOL)animated {
	if(editing != newEditing) {
		editing = newEditing;
		self.renderedImage = nil;
		[self setNeedsDisplay];
		if(editing) self.userInteractionEnabled = YES;
	}
}


// ========================================================================== //

#pragma mark - Events


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch* touch = [touches anyObject];
	NSUInteger numTaps = [touch tapCount];
	if(self.zoomsImage && ! self.editing) {
		if (numTaps == 2)
			[self zoomImage];
	}
	if(self.editing) {
		[[UIApplication sharedApplication] sendAction:@selector(beginImagePicking:) to:nil from:self forEvent:nil];
	}
}

- (void) zoomImage {
    FSQModalImageView *bigImageView = [[FSQModalImageView  alloc] initWithImage:self.image];
    bigImageView.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    [self.window addSubview:bigImageView];
	
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[self.window layer] addAnimation:animation forKey:@"ZoomingImageView"];    
}


@end
