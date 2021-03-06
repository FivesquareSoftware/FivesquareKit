//
//  UILabel+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 5/7/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "UILabel+FSQUIKit.h"

@implementation UILabel (FSQUIKit)

- (void) setFontName:(NSString *)fontName {
	UIFont *fontNamed = [UIFont fontWithName:fontName size:self.font.pointSize];
	self.font = fontNamed;
}

@end
