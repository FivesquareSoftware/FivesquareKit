//
//  FSQGradientView.m
//  FivesquareKit
//
//  Created by John Clayton on 5/6/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQGradientView.h"


@interface FSQGradientView ()
@property (nonatomic, readonly) CAGradientLayer *gradientLayer;
@end

@implementation FSQGradientView

+ (Class) layerClass {
	return [CAGradientLayer class];
}

// ========================================================================== //

#pragma mark - Properties

@dynamic gradientLayer;
- (CAGradientLayer *) gradientLayer {
	return (CAGradientLayer *)self.layer;
}

- (void) setGradientComponents:(NSArray *)gradientComponents {
	if (_gradientComponents != gradientComponents) {
		_gradientComponents = gradientComponents;
		self.gradientLayer.colors = [_gradientComponents valueForKey:@"color"];
		self.gradientLayer.locations = [_gradientComponents valueForKey:@"location"];
		[self setNeedsDisplay];
	}
}

@dynamic startPoint;
- (CGPoint) startPoint {
	return self.gradientLayer.startPoint;
}

- (void) setStartPoint:(CGPoint)startPoint {
	self.gradientLayer.startPoint = startPoint;
}

@dynamic endPoint;
- (CGPoint) endPoint {
	return self.gradientLayer.endPoint;
}

- (void) setEndPoint:(CGPoint)endPoint {
	self.gradientLayer.endPoint = endPoint;
}


// ========================================================================== //

#pragma mark - Object



- (void) initialize {
	self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void) ready {
	self.gradientLayer.colors = [_gradientComponents valueForKey:@"color"];
	self.gradientLayer.locations = [_gradientComponents valueForKey:@"location"];
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


@end
