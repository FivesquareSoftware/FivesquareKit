//
//  FSQSegmentedControl.h
//  FivesquareKit
//
//  Created by John Clayton on 2/14/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQSegmentedControl : UIControl <UIAppearance>


- (id)initWithItems:(NSArray *)items;

@property(nonatomic,readonly) NSUInteger numberOfSegments;
@property(nonatomic) NSInteger selectedSegmentIndex;

- (void) setbackgroundImageForLeftSegment:(UIImage *)image controlState:(UIControlState)controlState UI_APPEARANCE_SELECTOR;
- (void) setbackgroundImageForMiddleSegments:(UIImage *)image controlState:(UIControlState)controlStateUI_APPEARANCE_SELECTOR;
- (void) setbackgroundImageForRightSegment:(UIImage *)image controlState:(UIControlState)controlStateUI_APPEARANCE_SELECTOR;

- (void) setTitleColor:(UIColor *)color controlState:(UIControlState)controlState UI_APPEARANCE_SELECTOR;

@end
