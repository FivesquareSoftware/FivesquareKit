//
//  NSApplication+FSQAppKit.m
//  FivesquareKit
//
//  Created by John Clayton on 6/15/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSApplication+FSQAppKit.h"

#import "FSQAppKitConstants.h"

@implementation NSApplication (FSQAppKit)

- (void) blockSheetDidEnd:(NSWindow *)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void *)contextInfo {
	FSQSheetCompletionBlock completionBlock = (__bridge_transfer FSQSheetCompletionBlock)contextInfo;
	if (completionBlock) {
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(returnCode);
			Block_release(contextInfo);
		});
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		[sheet orderOut:self];
	});
}

- (void) displaySheet:(NSWindow *)sheet modalForWindow:(NSWindow *)window whileExecutingBlock:(FSQSheetExecutionBlock)executionBlock completionBlock:(FSQSheetCompletionBlock)completionBlock {
	[self beginSheet:sheet modalForWindow:window completionBlock:completionBlock];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSInteger returnCode = kFSQSheetExecutionBlockSuccess;
		if (executionBlock) {
			returnCode = executionBlock();
		}
		[window endSheet:sheet returnCode:returnCode];
	});
}

- (void) beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)window completionBlock:(FSQSheetCompletionBlock)completionBlock {
	FSQWeakSelf(welf);
	[window beginSheet:sheet completionHandler:^(NSModalResponse returnCode) {
		if (completionBlock) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completionBlock(returnCode);
			});
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[sheet orderOut:welf];
		});
	}];
}


@end
