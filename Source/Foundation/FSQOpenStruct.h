//
//  FSQOpenStruct.h
//  FivesquareKit
//
//  Created by John Clayton on 2/5/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQOpenStruct : NSObject <NSCoding>

@property (strong, readonly) NSMutableDictionary *attributes;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
- (instancetype) initWithContentsOfFile:(NSString *)file;

@end
