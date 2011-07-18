//
//  FSQKeyValueMapper.h
//  FivesquareKit
//
//  Created by John Clayton on 5/22/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSQKeyValueMapper : NSObject {
	NSArray *bindings;
}

@property (nonatomic, retain) NSArray *bindings;

+ (FSQKeyValueMapper *) mapperForClass:(Class)aClass;
- (id) initWithBindings:(NSArray *)someBindings;

- (void) mapSource:(id)source toTarget:(id)target;

@end
