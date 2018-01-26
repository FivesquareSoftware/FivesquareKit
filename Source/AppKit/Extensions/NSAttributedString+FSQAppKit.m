//
//  NSAttributedString+FSQAppKit.m
//  FivesquareKit
//
//  Created by John Clayton on 6/25/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSAttributedString+FSQAppKit.h"

#import <WebKit/WebKit.h>
#import "WebView+FSQWebKit.h"

@implementation NSAttributedString (FSQAppKit)

+ (NSAttributedString *) stringWithContentsOfURL:(NSURL *)URL {
	
	__block id string = nil;

	dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

	void (^block)(void) = ^{
		WebView *webView = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100) frameName:nil groupName:nil];
		
		[webView loadURL:URL completionHandler:^(NSError *error) {
			WebFrame *frame = [webView mainFrame];
			NSView <WebDocumentView> * documentView = [[frame frameView] documentView];
			if ([documentView conformsToProtocol:@protocol(WebDocumentText)]) {
				string = [(id<WebDocumentText>)documentView attributedString];
			}
			dispatch_semaphore_signal(semaphore);
		}];
	};
	
	if (NO == [NSThread isMainThread]) {
		dispatch_async(dispatch_get_main_queue(), block);
	} else {
		block();
	}
	
	dispatch_async(dispatch_get_main_queue(), block);

	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	return string;
}

@end
