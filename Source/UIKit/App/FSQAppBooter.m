//
//  FSQAppBooter.m
//  FivesquareKit
//
//  Created by John Clayton on 1/30/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQAppBooter.h"

#import "FSQAsserter.h"
#import "NSOperationQueue+FSQFoundation.h"

@implementation FSQAppBooter {
	BOOL booted;
	NSOperationQueue *bootQ;	
}

@synthesize delegate;

- (id)initWithBootOperations:(NSArray *)bootOperations {
    self = [super init];
    if (self) {
        bootQ = [[NSOperationQueue alloc] init];
		[bootQ setSuspended:YES];
    }
    return self;
}

- (void) addOperation:(NSOperation *)operation {
	FSQAssert(booted == NO, @"Booter already booted");
	[bootQ addOperationRecursively:operation];
}

- (void) addBootOperations:(NSArray *)operations {	
	FSQAssert(booted == NO, @"Booter already booted");
	for (NSOperation *op in operations) {
		[bootQ addOperationRecursively:op];
	}
}

- (void) boot {
	FSQAssert(booted == NO, @"Booter already booted");
	booted = YES;
	[self performSelectorInBackground:@selector(bootInBackground) withObject:nil];
}

- (void) bootInBackground {
	@autoreleasepool {
		[bootQ setSuspended:NO];	
		[bootQ waitUntilAllOperationsAreFinished];
	}
	[(NSObject *)self.delegate performSelectorOnMainThread:@selector(booterFinishedBooting:) withObject:self waitUntilDone:NO];
}




@end
