//
//  FSQGradientView.m
//  FivesquareKit
//
//  Created by John Clayton on 5/6/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQGradientView.h"

#import "FSQRadialGradientLayer.h"


NSString *kFSQGradientViewRadial = @"FSQGradientViewRadial";

@interface FSQGradientView ()
@property (nonatomic, weak) CAGradientLayer *gradientLayer;
@end

@implementation FSQGradientView

//+ (Class) layerClass {
//	return [CAGradientLayer class];
//}

// ========================================================================== //

#pragma mark - Properties

- (void) setGradientLayer:(CAGradientLayer *)gradientLayer {
	if (_gradientLayer != gradientLayer) {
		if (_gradientLayer) {
			[_gradientLayer removeFromSuperlayer];
		}
		gradientLayer.frame = self.bounds;
		[self.layer insertSublayer:gradientLayer atIndex:0];
		_gradientLayer = gradientLayer;
		[self setNeedsDisplay];
	}
}

- (void) setGradientComponents:(NSArray *)gradientComponents {
	if (_gradientComponents != gradientComponents) {
		_gradientComponents = gradientComponents;
		self.gradientLayer.colors = [_gradientComponents valueForKey:@"color"];
		self.gradientLayer.locations = [_gradientComponents valueForKey:@"location"];
		[self setNeedsDisplay];
	}
}

- (void) setStartPoint:(CGPoint)startPoint {
	if (NO == CGPointEqualToPoint(_startPoint, startPoint)) {
		_startPoint = startPoint;
		self.gradientLayer.startPoint = _startPoint;
		[self setNeedsDisplay];
	}
}

- (void) setEndPoint:(CGPoint)endPoint {
	if (NO == CGPointEqualToPoint(_endPoint, endPoint)) {
		_endPoint = endPoint;
		self.gradientLayer.endPoint = _endPoint;
		[self setNeedsDisplay];
	}
}

- (void) setType:(NSString *)type {
	if (_type != type) {
		_type = type;
		[self configureGradientLayer];
	}
}


// ========================================================================== //

#pragma mark - Object



- (void) initialize {
	self.translatesAutoresizingMaskIntoConstraints = NO;
	self.layer.masksToBounds = YES;
}

- (void) ready {
	_type = kCAGradientLayerAxial;
	[self configureGradientLayer];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
		[self ready];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self ready];
}

- (void) layoutSubviews {
	_gradientLayer.frame = self.bounds;
	_gradientLayer.cornerRadius = self.layer.cornerRadius;
}


// ========================================================================== //

#pragma mark - Helpers


- (void) configureGradientLayer {
	CAGradientLayer *newLayer = [self newGradientLayer];
	self.gradientLayer = newLayer;
}

- (CAGradientLayer *) newGradientLayer {
	CAGradientLayer *gradientLayer = nil;
	if ([_type isEqualToString:kCAGradientLayerAxial]) {
		gradientLayer = [CAGradientLayer layer];
	}
	else if ([_type isEqualToString:kFSQGradientViewRadial]) {
		gradientLayer = [FSQRadialGradientLayer layer];
	}
	
	gradientLayer.contentsScale = [[UIScreen mainScreen] scale];
	gradientLayer.shouldRasterize = YES;

	gradientLayer.needsDisplayOnBoundsChange = YES;
	gradientLayer.masksToBounds = YES;
	
	gradientLayer.colors = [_gradientComponents valueForKey:@"color"];
	gradientLayer.locations = [_gradientComponents valueForKey:@"location"];
	gradientLayer.startPoint = self.startPoint;
	gradientLayer.endPoint = self.endPoint;

	return gradientLayer;
}



@end
