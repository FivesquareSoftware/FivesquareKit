//
//  FSQCapsuleButton.h
//  FivesquareKit
//
//  Created by John Clayton on 8/6/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSQCapsuleButton : UIButton
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *highlightedFillColor; ///< Defaults to dimmed fillColor
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *highlightedBorderColor; ///< Defaults to borderColor
@property (nonatomic) CGFloat borderWidth; ///< Defaults to 2
@end
