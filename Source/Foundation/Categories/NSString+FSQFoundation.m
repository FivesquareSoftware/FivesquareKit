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

#import "FSQAsserter.h"
#import "NSObject+FSQFoundation.h"


//static NSString *kFSQ_NSStringPathWithOptionalScaleExpression = @"^(\\w+)(@([0-9.]+)x)?(\\.([^.]+))$";

@implementation NSString (FSQFoundation)

+ (BOOL) isEmpty:(NSString *)obj {
	BOOL isEmpty = [NSObject isEmpty:obj];
	if (isEmpty) {
		return isEmpty;
	}
	return [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 1;
}

+ (BOOL) isNotEmpty:(NSString *)string {
	return NO == [self isEmpty:string];
}

- (NSString *) MD5Hash {
	const char *cStr = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
	
	NSMutableString *hash = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
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

- (NSString *) stringByDeletingScaleModifier {
	NSString *string = nil;
	NSRegularExpression *scaleExpression = [NSRegularExpression regularExpressionWithPattern:@"(@[0-9.]+x)(\\.([^.]+))?$" options:0 error:NULL];
	NSTextCheckingResult *match = [scaleExpression firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
	if (match) {
		NSString *template;
		if ([match rangeAtIndex:2].location != NSNotFound) {
			template = @"$2";
		} else {
			template = @"";
		}
		string = [scaleExpression stringByReplacingMatchesInString:self options:0 range:match.range withTemplate:template];
	} else {
		string = [self copy];
	}
	FSQAssert(string,@"Failed to create descaled string!");
	return string;
}

- (NSString *)substringAsFarAsIndex:(NSUInteger)anIndex {
	NSUInteger length = self.length;
	if (anIndex >= length) {
		anIndex = length;
	}
	return [self substringToIndex:anIndex];
}

- (NSString *) substringAroundRange:(NSRange)range padding:(NSUInteger)paddingCharacters matchWords:(BOOL)matchWords {
	NSRange totalRange = NSMakeRange(0, self.length);
	NSUInteger midRange = range.location+(range.length/2);
	NSRange newRange = NSMakeRange(NSNotFound, 0);
	
	NSInteger rangeMin = (NSInteger)midRange-(NSInteger)paddingCharacters;
	if (rangeMin < 0) {
		rangeMin = 0;
	}

	NSUInteger rangeMax = midRange + paddingCharacters;
	if (rangeMax > NSMaxRange(totalRange)) {
		rangeMax = NSMaxRange(totalRange);
	}
	
	newRange.location = (NSUInteger)rangeMin;
	newRange.length = rangeMax-newRange.location;
	
	__block NSRange wordsRange = NSMakeRange(NSNotFound, 0);
	if (matchWords) {
		__block NSUInteger idx = 0;
		[self enumerateSubstringsInRange:newRange options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			if (idx++ == 0) {
				wordsRange.location = substringRange.location;
			}
			else {
				wordsRange.length = NSMaxRange(substringRange)-wordsRange.location;
			}
		}];
	}

	if (wordsRange.location != NSNotFound) {
		newRange = wordsRange;
	}

	NSString *newString = [self substringWithRange:newRange];
	return newString;
}

- (NSDictionary *) dictionaryWithEntriesSeparatedBy:(NSString *)entryDelimiter keysAndValuesSeparatedBy:(NSString *)keyValueSeparator {
	NSMutableDictionary *dictionary = [NSMutableDictionary new];
	NSArray *entries = [self componentsSeparatedByString:entryDelimiter];
	for (NSString *entry in entries) {
		NSArray *keyValuePair = [entry componentsSeparatedByString:keyValueSeparator];
		if ([keyValuePair count] == 2) {
			dictionary[keyValuePair[0]] = keyValuePair[1];
		}
	}
	return dictionary;
}

- (NSDictionary *) dictionaryWithURLEncoding {
	return [self dictionaryWithEntriesSeparatedBy:@"&" keysAndValuesSeparatedBy:@"="];
}

- (NSString *) indexString {
	NSString *indexString = [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
	return [indexString lowercaseString];
}

@end
