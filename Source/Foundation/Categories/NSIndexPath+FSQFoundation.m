//
//  NSIndexPath+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 1/4/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "NSIndexPath+FSQFoundation.h"

@implementation NSIndexPath (FSQFoundation)

- (NSString *) toString {
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"["];
    NSUInteger count = [self length];
    for (NSUInteger i = 0; i < count; i++) {
        NSString *delimiter = i == 0 ? @"" : @",";
        [string appendFormat:@"%@%@",delimiter,@([self indexAtPosition:i])];
    }
    [string appendString:@"]"];
    return string;
}

@end
