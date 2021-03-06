//
//  FSQThumbstripCell.m
//  FivesquareKit
//
//  Created by John Clayton on 4/19/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQThumbstripCell.h"

#import "FSQAsserter.h"

@interface FSQThumbstripCell ()
@property (nonatomic, strong, readwrite) NSString *reuseIdentifier;
@end


@implementation FSQThumbstripCell


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
		contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		contentView.backgroundColor = [UIColor clearColor];
		[self addSubview:contentView];
		_contentView = contentView;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) prepareForReuse {
	FSQSubclassWarn();
}

@end
