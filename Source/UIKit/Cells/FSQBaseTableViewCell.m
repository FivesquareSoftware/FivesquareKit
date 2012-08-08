//
//  FSQBaseTableViewCell.m
//  FivesquareKit
//
//  Created by John Clayton on 8/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQBaseTableViewCell.h"

@implementation FSQBaseTableViewCell

- (void) initialize {
#ifdef __IPHONE_6_0
//	self.translatesAutoresizingMaskIntoConstraints = NO; // Crashes as of 6b3
#endif
	
}

- (void) ready {
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
