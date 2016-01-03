//
//  UIScreen+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 10/8/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "UIScreen+FSQUIKit.h"

@implementation UIScreen (FSQUIKit)

- (BOOL) isShortScreen {
	return self.bounds.size.height < 568.;
}

- (BOOL) isFourInchScreen {
	return self.bounds.size.height == 568.;
}

- (BOOL) isBigScreen {
	return self.bounds.size.height >= 736.;
}

- (CGFloat) aspect {
	return self.bounds.size.width/self.bounds.size.height;
}

@end
