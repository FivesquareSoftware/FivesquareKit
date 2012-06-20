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

- (void) blockSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
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
		[self endSheet:sheet returnCode:returnCode];
	});
}

- (void) beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)window completionBlock:(FSQSheetCompletionBlock)completionBlock {
	void *contextInfo = Block_copy((__bridge void *)completionBlock);
	[self beginSheet:sheet modalForWindow:window modalDelegate:self didEndSelector:@selector(blockSheetDidEnd:returnCode:contextInfo:) contextInfo:contextInfo];
}


@end
