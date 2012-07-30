//
//  NSError+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 7/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSError+FSQFoundation.h"

@implementation NSError (FSQFoundation)

+ (id) withException:(NSException *)exception {
	NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"An exception occurred: %@",[exception name]], @"exception" : exception, @"reason" : [exception reason] , @"callStackSymbols" : [exception callStackSymbols], @"userInfo" : [exception userInfo] };
	NSError *error = [NSError errorWithDomain:@"ExceptionDomain" code:-999 userInfo:info];
	return error;
}

@end
