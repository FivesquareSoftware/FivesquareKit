//
//  FSQLabel.h
//  FivesquareKit
//
//  Created by John Clayton on 7/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __IPHONE_6_0

@interface FSQLabel : UILabel

@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic) BOOL collapseWhenEmpty;

@end

#endif
