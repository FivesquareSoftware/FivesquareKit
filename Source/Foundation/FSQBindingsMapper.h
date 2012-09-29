//
//  FSQKeyValueMapper.h
//  FivesquareKit
//
//  Created by John Clayton on 5/22/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FSQBindingsMapperMergePolicy) {
	FSQBindingsMapperMergePolicySourceObjectTrumpsDestination		= 0 // the source object is mapped over the top of the target object, including nil values
	, FSQBindingsMapperMergePolicyDestinationObjectTrumpsSource		= 1 // if the target object has a value to merge with, that value wins
};

@interface FSQBindingsMapper : NSObject

@property (nonatomic, retain) NSArray *bindings;
@property (nonatomic) FSQBindingsMapperMergePolicy mergePolicy; ///> Defaults to FSQBindingsMapperMergePolicySourceObjectTrumpsDestination

+ (id) mapperForClass:(Class)aClass;
+ (id) withBindingsNamed:(NSString *)name;
- (id) initWithBindings:(NSArray *)someBindings;

- (BOOL) mapSource:(id)source toTarget:(id)target error:(NSError **)error;

@end
