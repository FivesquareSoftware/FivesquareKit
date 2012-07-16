//
//  FSQProxy.m
//  FivesquareKit
//
//  Created by John Clayton on 5/30/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQProxy.h"


@implementation FSQProxy


+ (id) withTarget:(id)aTarget {
	return [[FSQProxy alloc] initWithTarget:aTarget];
}

- (id) initWithTarget:(id)aTarget {
	// there is no -init in NSProxy
	self.target = aTarget;
	return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [_target methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	[invocation invokeWithTarget:_target];
}


@end
