//
//  FSQPropertyMapper.h
//  FivesquareKit
//
//  Created by John Clayton on 2/22/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQPropertyMapper : NSObject

+ (id) withTargetObject:(NSObject *)target;
- (id) initWithTargetObject:(NSObject *)target;

- (BOOL) mapFromObject:(NSObject *)source error:(NSError **)error;

@end
