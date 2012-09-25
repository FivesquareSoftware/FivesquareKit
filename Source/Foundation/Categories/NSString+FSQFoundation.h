//
//  NSString+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 7/3/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (FSQFoundation)

+ (BOOL) isEmpty:(NSString *)string;
+ (BOOL) isNotEmpty:(NSString *)string;

- (NSString *) MD5Hash;

- (BOOL) contains:(NSString *)aString options:(NSStringCompareOptions)mask;
- (BOOL) startsWith:(NSString *)aString options:(NSStringCompareOptions)mask;

- (BOOL) isValidEmailAddress;

- (NSString *) stringByDeletingScaleModifier;
- (NSString *) substringAsFarAsIndex:(NSUInteger)anIndex; ///< A safe version of substringToIndex: that checks the index for a range exception
- (NSString *) substringAroundRange:(NSRange)range padding:(NSUInteger)paddingCharacters matchWords:(BOOL)matchWords;

@end
