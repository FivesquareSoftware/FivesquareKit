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

@synthesize reuseIdentifier=reuseIdentifier_;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        reuseIdentifier_ = reuseIdentifier;
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
