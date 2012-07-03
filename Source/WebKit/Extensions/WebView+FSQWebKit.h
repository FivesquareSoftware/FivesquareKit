//
//  WebView+FSQWebKit.h
//  FivesquareKit
//
//  Created by John Clayton on 6/25/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WebView (FSQWebKit)

- (void) loadURL:(NSURL *)URL completionHandler:(void(^)(NSError *error))completionHandler;

@end
