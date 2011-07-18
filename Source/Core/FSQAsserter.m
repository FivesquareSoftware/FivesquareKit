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
	[[NSAssertionHandler currentHandler] handleFailureInMethod:selector 
														object:object 
														  file:[NSString stringWithUTF8String:fileName] 
													lineNumber:lineNumber 
												   description:msg];
#else
	NSLog(@" *** Assertion Failed *** ");
	NSLog(msg);
#endif
	
}

@end
