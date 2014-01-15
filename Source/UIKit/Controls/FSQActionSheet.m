//
//  FSQActionSheet.m
//  FivesquareKit
//
//  Created by John Clayton on 1/14/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQActionSheet.h"

@interface FSQActionSheet () <UIActionSheetDelegate>
@property (nonatomic, copy) void(^dismissHandler)(UIActionSheet *actionSheet, NSInteger buttonIndex);
@end

@implementation FSQActionSheet

- (void) showInView:(UIView *)view withDismissHandler:(void(^)(UIActionSheet *actionSheet, NSInteger buttonIndex))dismissHandler {
	self.delegate = self;
	self.dismissHandler = dismissHandler;
	[self showInView:view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (self.dismissHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.dismissHandler(self,buttonIndex);
			self.dismissHandler = nil;
		});
	}
}

@end
