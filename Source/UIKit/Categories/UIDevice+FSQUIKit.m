//
//  UIDevice+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 5/10/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "UIDevice+FSQUIKit.h"

#import <sys/sysctl.h>

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

- (NSString *) modelName {
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *modelName = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
	return modelName;
}

@dynamic iPhone4;
- (BOOL) iPhone4 {
	NSString *modelName = [self modelName];
	if (	[modelName isEqualToString:@"iPhone3,1"]
		||	[modelName isEqualToString:@"iPhone3,3"]
		||	[modelName isEqualToString:@"iPhone4,1"]) {
		return YES;
	}
	return NO;
}


@dynamic iPhone5;
- (BOOL) iPhone5 {
	NSString *modelName = [self modelName];
	if (	[modelName isEqualToString:@"iPhone5,1"]
		||	[modelName isEqualToString:@"iPhone5,2"]
		||	[modelName isEqualToString:@"iPhone5,3"]
		||	[modelName isEqualToString:@"iPhone5,4"]
		||	[modelName isEqualToString:@"iPhone6,1"]
		||	[modelName isEqualToString:@"iPhone6,2"]) {
		return YES;
	}
	return NO;
}

@dynamic iPhone6;
- (BOOL) iPhone6 {
	NSString *modelName = [self modelName];
	if ([modelName isEqualToString:@"iPhone7,2"]) {
		return YES;
	}
	return NO;
}

@dynamic iPhone6Simulator;
- (BOOL) iPhone6Simulator {
	NSString *modelName = [self modelName];
	if ([modelName isEqualToString:@"x86_64"] && [UIScreen mainScreen].bounds.size.height == 667.) {
		return YES;
	}
	return NO;
}

@dynamic iPhone6Plus;
- (BOOL) iPhone6Plus {
	NSString *modelName = [self modelName];
	if ([modelName isEqualToString:@"iPhone7,1"]) {
		return YES;
	}
	return NO;
}

@dynamic iPhone6PlusSimulator;
- (BOOL) iPhone6PlusSimulator {
	NSString *modelName = [self modelName];
	if ([modelName isEqualToString:@"x86_64"] && [UIScreen mainScreen].bounds.size.height == 736.) {
		return YES;
	}
	return NO;
}

- (NSString *) newPersistentIdentifier {
	//???: Just using a UUID right now, it would be nice if this was tied to hardware like net interface or something so it could be recreated reliably
	CFUUIDRef newUUID = CFUUIDCreate(NULL);
	CFStringRef UUIDString = CFUUIDCreateString(NULL, newUUID);
	CFRelease(newUUID);
	return (NSString *)CFBridgingRelease(UUIDString);
}

@end
