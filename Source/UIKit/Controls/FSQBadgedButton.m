//
//  FSQBadgedButton.m
//  FivesquareKit
//
//  Created by John Clayton on 6/20/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQBadgedButton.h"
#import "FSQBadgeView.h"

@interface FSQBadgedButton ()
@property (nonatomic, weak) FSQBadgeView *badgeView;

@end

@implementation FSQBadgedButton

// ========================================================================== //

#pragma mark - Properties


@dynamic badgeValue;
- (NSString *) badgeValue {
	return _badgeView.stringValue;
}

- (void) setBadgeValue:(NSString *)badgeValue {
	_badgeView.stringValue = badgeValue;
}


// ========================================================================== //

#pragma mark - View


- (void) initialize {
//	self.translatesAutoresizingMaskIntoConstraints = NO;
	self.clipsToBounds = NO;
	_badgePosition = FSQBadgeButtonBadgePositionTopLeft;
}

- (void) ready {
	FSQBadgeView *badgeView = [[FSQBadgeView alloc] initWithFrame:CGRectZero];
	[self addSubview:badgeView];
//	badgeView.hidden = YES;
	_badgeView = badgeView;
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
	[super layoutSubviews];
	
	CGRect badgeBounds = _badgeView.bounds;
//	CGFloat halfBadgeDimension = badgeBounds.size.width/2.f;
//	CGFloat quarterBadgeDimension = halfBadgeDimension/2.f;
//	CGFloat oneThirdWidth = badgeBounds.size.width/3.f;
	
	CGFloat offset = badgeBounds.size.width/2.f;
	
	switch (_badgePosition) {
		case FSQBadgeButtonBadgePositionTopLeft:
			_badgeView.center = CGPointMake(offset, offset);
			break;
		case FSQBadgeButtonBadgePositionTopRight:
			_badgeView.center = CGPointMake(CGRectGetMaxX(self.bounds)-offset, offset);
			break;
		case FSQBadgeButtonBadgePositionBottomRight:
			_badgeView.center = CGPointMake(CGRectGetMaxX(self.bounds)-offset, CGRectGetMaxY(self.bounds)-offset);
			break;
		case FSQBadgeButtonBadgePositionBottomLeft:
			_badgeView.center = CGPointMake(offset, CGRectGetMaxY(self.bounds)-offset);
			break;
			
		default:
			break;
	}

}


@end
