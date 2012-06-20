//
//  NSApplication+FSQAppKit.h
//  FivesquareKit
//
//  Created by John Clayton on 6/15/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FSQAppKitTypes.h"

@interface NSApplication (FSQAppKit)

- (void) beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)window completionBlock:(FSQSheetCompletionBlock)completionBlock;
- (void) displaySheet:(NSWindow *)sheet modalForWindow:(NSWindow *)window whileExecutingBlock:(FSQSheetExecutionBlock)executionBlock completionBlock:(FSQSheetCompletionBlock)completionBlock;

@end
