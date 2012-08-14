//
//  UIDevice+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 5/10/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIDevice+FSQUIKit.h"

@implementation UIDevice (FSQUIKit)

@dynamic iPad;
- (BOOL) iPad {
	if([self respondsToSelector:@selector(userInterfaceIdiom)]) {
		return [self userInterfaceIdiom] == UIUserInterfaceIdiomPad;
	}
	return NO;
}

@dynamic iPhone;
- (BOOL) iPhone {
	if([self respondsToSelector:@selector(userInterfaceIdiom)]) {
		return [self userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
	}
	return YES;
}

- (NSString *) newPersistentIdentifier {
	//???: Just using a UUID right now, it would be nice if this was tied to hardware like net interface or something so it could be recreated reliably
	CFUUIDRef newUUID = CFUUIDCreate(NULL);
	CFStringRef UUIDString = CFUUIDCreateString(NULL, newUUID);
	CFRelease(newUUID);
	return (NSString *)CFBridgingRelease(UUIDString);
}

@end
