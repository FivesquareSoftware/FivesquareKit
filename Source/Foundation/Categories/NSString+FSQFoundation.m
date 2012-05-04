//
//  NSString+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 7/3/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "NSString+FSQFoundation.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


@implementation NSString (FSQFoundation)

- (BOOL) isEmpty:(NSString *)string {
	return string == nil || [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

- (NSString *) MD5Hash {
	const char *cStr = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, strlen(cStr), result );
	
	NSMutableString *hash = [[NSMutableString alloc] initWithCapacity:33];
	for (int i = 0; i < 16; i++) {
		[hash appendFormat: @"%02x", result[i]];
	}
	
	return hash;
}

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
