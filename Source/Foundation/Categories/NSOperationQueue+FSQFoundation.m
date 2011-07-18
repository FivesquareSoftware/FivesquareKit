//
//  NSOperationQueue+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 7/17/11.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "NSOperationQueue+FSQFoundation.h"

@implementation NSOperationQueue (FSQFoundation)

- (void)addOperationRecursively:(NSOperation *)operation {
	[self addOperation:operation];
	
	for (NSOperation *theDependency in operation.dependencies) {
		[self addOperationRecursively:theDependency];
	}
}

@end
