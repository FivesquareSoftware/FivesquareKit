//
//  NSWindow+FSQAppKit.m
//  FivesquareKit
//
//  Created by John Clayton on 6/15/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSWindow+FSQAppKit.h"

#import "NSApplication+FSQAppKit.h"

@implementation NSWindow (FSQAppKit)

- (void) beginSheetModalForWindow:(NSWindow *)window completionBlock:(FSQSheetCompletionBlock)block {
	[NSApp beginSheet:self modalForWindow:window completionBlock:block];
}

- (void) displaySheetModalForWindow:(NSWindow *)window whileExecutingBlock:(FSQSheetExecutionBlock)executionBlock completionBlock:(FSQSheetCompletionBlock)completionBlock {
	[NSApp displaySheet:self modalForWindow:window whileExecutingBlock:executionBlock completionBlock:completionBlock];
}

@end
