//
//  FSQAssertions.h
//  FivesquareKit
//
//  Created by John Clayton on 10/14/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FSQAssert(condition, format, args...) if( ! (condition) ) [FSQAsserter assertionFailedInMethod:_cmd object:self file:__FILE__ lineNumber:__LINE__ message: format, ## args]

/** Replaces NSAssert and when assertions are turned off still logs an error message to console. */
@interface FSQAsserter : NSObject {

}

+ (void) assertionFailedInMethod:(SEL)selector
						  object:(id)object
							file:(char *) fileName
					  lineNumber:(int) lineNumber
						 message:(NSString *)aFormat,...;
	
@end
