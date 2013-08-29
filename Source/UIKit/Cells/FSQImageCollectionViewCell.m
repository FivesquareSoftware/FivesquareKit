//
//  FSQImageCollectionViewCell.m
//  FivesquareKit
//
//  Created by John Clayton on 6/8/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQImageCollectionViewCell.h"

@implementation FSQImageCollectionViewCell

- (void) initialize {
	self.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void) ready {
	if (nil == _imageView) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:imageView];
		_imageView = imageView;
	}
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

- (void) setSelected:(BOOL)selected {
	[super setSelected:selected];
	self.highlighted = selected;
}

- (void) setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	_imageView.highlighted = highlighted;
}

@end
