//
//  FSQTransparentWebView.m
//  FivesquareKit
//
//  Created by John Clayton on 3/26/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTransparentWebView.h"

@implementation FSQTransparentWebView

- (void) initialize {
//	self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void) ready {
	self.opaque = NO;
	self.backgroundColor = [UIColor clearColor];
	[self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		if ([subview isKindOfClass:[UIScrollView class]]) {
			[[subview.subviews copy] enumerateObjectsUsingBlock:^(UIView *subview2, NSUInteger idx2, BOOL *stop2) {
				if ([subview2 isKindOfClass:[UIImageView class]]) {
					[subview2 removeFromSuperview];
				}
			}];
			*stop = YES;
		}
	}];
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
