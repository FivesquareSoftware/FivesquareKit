//
//  FSQProgressBar.h
//  FivesquareKit
//
//  Created by John Clayton on 5/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQProgressBar : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic, strong) NSArray *progressTrackGradientComponents;
@property (nonatomic, strong) NSArray *progressTintGradientComponents;

@end
