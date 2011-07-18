//
//  NSData+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 9/27/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "NSData+FSQFoundation.h"


@implementation NSData (FSQFoundation)


- (NSString *) hexString {
	return [[[[self description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
									stringByReplacingOccurrencesOfString:@">" withString:@""] 
								   stringByReplacingOccurrencesOfString: @" " withString: @""];
}


@end
