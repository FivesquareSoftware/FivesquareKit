//
//  NSAttributedString+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 8/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSAttributedString+FSQFoundation.h"

@implementation NSAttributedString (FSQFoundation)

+ (BOOL) isEmpty:(NSAttributedString *)string {
	return string == nil || [string length] < 1;

}

@end
