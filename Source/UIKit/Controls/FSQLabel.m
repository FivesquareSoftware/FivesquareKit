//
//  FSQLabel.m
//  FivesquareKit
//
//  Created by John Clayton on 7/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQLabel.h"

#import "NSString+FSQFoundation.h"


@implementation FSQLabel

@synthesize textColor = _textColorInternal;

- (void) setText:(NSString *)text {
	if ([NSString isEmpty:text]) {
		text = _placeholderText;
		self.textColor = _placeholderColor;
	}
	else {
		self.textColor = _textColorInternal;
	}
	[super setText:text];
}

- (void) initialize {
#ifdef __IPHONE_6_0
	self.translatesAutoresizingMaskIntoConstraints = NO;
#endif
	_placeholderColor = [UIColor lightTextColor];
	[self setTextColor:_placeholderColor];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
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



@end
