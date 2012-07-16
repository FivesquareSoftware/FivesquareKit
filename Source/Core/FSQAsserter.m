//
//  FSQAssertions.m
//  FivesquareKit
//
//  Created by John Clayton on 10/14/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQAsserter.h"

#import "FSQLogging.h"

@implementation FSQAsserter

+ (void) subclass:(id)subclass responsibility:(SEL)sel {
	FSQAssert(NO, @"Implement %@ in your subclass (%@)",NSStringFromSelector(sel),subclass);
}

+ (void) subclass:(id)subclass warn:(SEL)sel {
	FSQAssert(@"Implement %@ in your subclass (%@)",NSStringFromSelector(sel),subclass);
}


+ (void) assertionFailedInMethod:(SEL)selector
						  object:(id)object
							file:(char *) fileName
					  lineNumber:(int) lineNumber
						 message:(NSString *)aFormat,... {
	va_list args;
	va_start(args,aFormat);
	NSString *msg = [[NSString alloc] initWithFormat:aFormat arguments:args];
	va_end(args);        

#ifndef NS_BLOCK_ASSERTIONS
	FLog(msg);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"
	[[NSAssertionHandler currentHandler] handleFailureInMethod:selector object:object file:@(fileName) lineNumber:lineNumber description:msg];
#pragma clang diagnostic pop

	
#else
	NSLog(@" *** Assertion Failed *** ");
	NSLog(msg);
#endif
	
}

@end
