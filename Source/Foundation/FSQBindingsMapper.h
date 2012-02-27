//
//  FSQKeyValueMapper.h
//  FivesquareKit
//
//  Created by John Clayton on 5/22/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSQBindingsMapper : NSObject

@property (nonatomic, retain) NSArray *bindings;

+ (id) mapperForClass:(Class)aClass;
+ (id) withBindingsNamed:(NSString *)name;
- (id) initWithBindings:(NSArray *)someBindings;

- (BOOL) mapSource:(id)source toTarget:(id)target error:(NSError **)error;

@end
