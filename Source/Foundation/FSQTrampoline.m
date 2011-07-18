//
//  FSQTrampoline.m
//  FivesquareKit
//
//  Created by John Clayton on 5/30/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTrampoline.h"


@implementation FSQTrampoline

@synthesize target=target_;

+ (id) withTarget:(id)aTarget {
	return [[FSQTrampoline alloc] initWithTarget:aTarget];
}

- (id) initWithTarget:(id)aTarget {
	// there is no -init in NSProxy
	self.target = aTarget;
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [target_ methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	[invocation invokeWithTarget:target_];
}


@end
