//
//  WebView+FSQWebKit.m
//  FivesquareKit
//
//  Created by John Clayton on 6/25/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "WebView+FSQWebKit.h"

#import <WebKit/WebKit.h>

@interface FSQTransientWebKitDelegate : NSObject 
@property (nonatomic, strong) id lifetime;
@property (nonatomic, copy) void (^completionHandler)(NSError *error);
@end

@implementation FSQTransientWebKitDelegate

@synthesize lifetime = _lifetime;
@synthesize completionHandler = _completionHandler;

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	if (_completionHandler) {
		_completionHandler(nil);
	}
	_lifetime = nil;
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	if (_completionHandler) {
		_completionHandler(error);
	}
	_lifetime = nil;
}

@end


@implementation WebView (FSQWebKit)

- (void) loadURL:(NSURL *)URL completionHandler:(void(^)(NSError *error))completionHandler {
	FSQTransientWebKitDelegate *delegate = [FSQTransientWebKitDelegate new];
	delegate.lifetime = delegate;
	delegate.completionHandler = completionHandler;
	
	self.frameLoadDelegate = delegate;
	[self setMainFrameURL:[URL absoluteString]];
}

@end
