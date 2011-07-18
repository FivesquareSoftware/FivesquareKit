//
//  UIBarButtonItem+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 2/15/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "UIBarButtonItem+FSQUIKit.h"


@implementation UIBarButtonItem (FSQUIKit)

- (UIView *) buttonView {
	UIView *buttonView = nil;
	
	SEL viewSelector = @selector(view);
	if([self respondsToSelector:viewSelector]) {
		buttonView = [self performSelector:viewSelector];
	}
	
	return buttonView;
}

@end
