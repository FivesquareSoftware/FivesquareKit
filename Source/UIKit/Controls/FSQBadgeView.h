//
//  FSQBadgeView.h
//  FivesquareKit
//
//  Created by John Clayton on 6/20/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSQBadgeView : UIView
@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSArray *badgeGradient UI_APPEARANCE_SELECTOR;
- (void) setTitleTextAttributes:(NSDictionary *)attributes UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSNumber *numberValue;
@property (nonatomic, strong) NSString *stringValue;

@end
