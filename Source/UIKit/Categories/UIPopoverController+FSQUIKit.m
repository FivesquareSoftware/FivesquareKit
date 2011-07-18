    //
//  UIPopoverController+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 2/10/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "UIPopoverController+FSQUIKit.h"

#import "UIViewController+FSQUIKit.h"

@implementation UIPopoverController (FSQUIKit)


+ (id) createWithContentController:(UIViewController *)controller delegate:(id<UIPopoverControllerDelegate>)popoverDelegate {
	if (!NSClassFromString(@"UIPopoverController"))
		return nil;
	
	UIPopoverController *popover = [[self alloc] initWithContentViewController:controller];	
	[controller setPopoverController:popover];
	[popover setDelegate:popoverDelegate];
	
	return popover;
}

+ (id) createPopoverWithContentView:(UIView *)contentView
{
	if (!NSClassFromString(@"UIPopoverController"))
		return nil;
	UIViewController *controller = [[UIViewController alloc] init];
	[controller.view addSubview:contentView];
	UIPopoverController *popover = [[self alloc] initWithContentViewController:controller];	
	[popover setPopoverContentSize:contentView.frame.size];
	
	return popover;	
}
	


@end
