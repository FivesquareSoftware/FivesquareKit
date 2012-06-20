//
//  NSWindow+FSQAppKit.h
//  FivesquareKit
//
//  Created by John Clayton on 6/15/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FSQAppKitTypes.h"


@interface NSWindow (FSQAppKit)

- (void) beginSheetModalForWindow:(NSWindow *)window completionBlock:(FSQSheetCompletionBlock)block;

- (void) displaySheetModalForWindow:(NSWindow *)window whileExecutingBlock:(FSQSheetExecutionBlock)executionBlock completionBlock:(FSQSheetCompletionBlock)completionBlock;


@end
