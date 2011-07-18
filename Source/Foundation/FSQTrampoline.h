//
//  FSQTrampoline.h
//  FivesquareKit
//
//  Created by John Clayton on 5/30/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Proxies a target object, allowing for easy construction and invocation of
 *  NSInvocations for methods in that object.
 */
@interface FSQTrampoline : NSProxy {
}

@property (nonatomic, retain) id target;

+ (id) withTarget:(id)aTarget;
- (id) initWithTarget:(id)aTarget;

@end
