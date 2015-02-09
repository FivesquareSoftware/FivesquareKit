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


@interface FSQAppBooter()
@property (nonatomic) BOOL booted;
@property (strong) NSOperationQueue *bootQ;
@property (strong) NSMutableArray *errorsInternal;
@property (copy) void (^completionBlock)(void);

- (void) bootInBackground;

@end


@implementation FSQAppBooter

// ========================================================================== //

#pragma mark - Properties


// Public

@dynamic errors;
- (NSArray *) errors {
	return [self.errorsInternal copy];
}

@dynamic failed;
- (BOOL) failed {
	return [self.errorsInternal count] > 0;
}

// Private



// ========================================================================== //

#pragma mark - Object



- (id)init {
    self = [super init];
    if (self) {
        self.bootQ = [NSOperationQueue new];
		[_bootQ setSuspended:YES];
		self.errorsInternal = [NSMutableArray new];
    }
    return self;
}



// ========================================================================== //

#pragma mark - Public




- (void) addOperation:(NSOperation *)operation {
	FSQAssert(self.booted == NO, @"Booter already booted");
	[self.bootQ addOperationRecursively:operation];
}

- (void) addBlock:(void (^)(void))block {
	NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:block];
	[self.bootQ addOperation:blockOp];
}

- (void) addWaitBlock:(void (^)(dispatch_semaphore_t wait_semaphore))block {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        block(semaphore);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        dispatch_semaphore_signal(semaphore);
//        dispatch_release(semaphore);
    }];
	[self.bootQ addOperation:blockOp];
}

- (void) bootWithCompletionBlock:(void (^)(void))block {
	FSQAssert(_booted == NO, @"Already booted!");
	if (_booted) return;

	_booted = YES;
	self.completionBlock = block;
	[self performSelectorInBackground:@selector(bootInBackground) withObject:nil];
}

- (void) addError:(NSError *)error {
	[self.errorsInternal addObject:error];
}


// ========================================================================== //

#pragma mark - Helpers



- (void) bootInBackground {
	@autoreleasepool {
		NSDate *startDate = [NSDate date];
		[self.bootQ setSuspended:NO];	
		[self.bootQ waitUntilAllOperationsAreFinished];
		[NSThread sleepUntilDate:[startDate dateByAddingTimeInterval:_minimumBootTime]];
		if (_completionBlock) {
			dispatch_async(dispatch_get_main_queue(), _completionBlock);
		}
		
	}
}





@end
