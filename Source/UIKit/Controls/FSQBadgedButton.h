//
//  FSQBadgedButton.h
//  FivesquareKit
//
//  Created by John Clayton on 6/20/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FSQBadgeButtonBadgePosition) {
	FSQBadgeButtonBadgePositionTopLeft,
	FSQBadgeButtonBadgePositionTopRight,
	FSQBadgeButtonBadgePositionBottomRight,
	FSQBadgeButtonBadgePositionBottomLeft,
};


@interface FSQBadgedButton : UIButton

@property (nonatomic) FSQBadgeButtonBadgePosition badgePosition;
@property (nonatomic, strong) NSString *badgeValue;

@end
