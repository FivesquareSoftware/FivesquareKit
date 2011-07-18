//
//  NSString+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 7/3/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "NSString+FSQFoundation.h"


@implementation NSString (FSQFoundation)

- (BOOL) contains:(NSString *)aString options:(NSStringCompareOptions)mask {
    return [self rangeOfString:aString options:mask].location != NSNotFound;
}

- (BOOL) startsWith:(NSString *)aString options:(NSStringCompareOptions)mask {
    return [self 
            compare:aString 
            options:mask 
            range:NSMakeRange(0, [aString length])] == NSOrderedSame;
}

- (BOOL) isValidEmailAddress {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:self];
}

@end
