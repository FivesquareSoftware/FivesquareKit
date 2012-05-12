//
//  UIDevice+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 5/10/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIDevice+FSQUIKit.h"

@implementation UIDevice (FSQUIKit)

@dynamic iPad;
- (BOOL) iPad {
	if([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
		return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
	}
	return NO;
}

@dynamic iPhone;
- (BOOL) iPhone {
	if([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
		return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
	}
	return YES;
}

@end
