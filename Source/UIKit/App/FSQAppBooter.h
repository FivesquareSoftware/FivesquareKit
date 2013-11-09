//
//  FSQAppBooter.h
//  FivesquareKit
//
//  Created by John Clayton on 1/30/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSQAppBooter;

typedef void(^FSQBootBlock)(FSQAppBooter *booter);
typedef void(^FSQBootWaitBlock)(dispatch_semaphore_t wait_semaphore,FSQAppBooter *booter);

@interface FSQAppBooter : NSObject



@property (nonatomic) NSTimeInterval minimumBootTime;

@property (nonatomic, readonly) NSArray *errors;
@property (nonatomic) BOOL failed; ///< YES if the count of errors is greater than 0


- (void) addOperation:(NSOperation *)operation; ///< Adds an operation and its dependents to the boot queue
- (void) addBlock:(FSQBootBlock)block; ///< Adds a block to the boot queue
/** Adds block to the boot Q, passing a semaphore with one lock as an argument. When the passed block is done with its work it must call dispatch_semaphore_signal() on the passed semaphore. This allows a block to perform work asynchronously but have the boot Q wait on its completion. */
- (void) addWaitBlock:(FSQBootWaitBlock)block;


/** Starts booting and returns immediately. */
- (void) boot;
/** Starts booting and returns immediately. The completion block will run on the main thread when booting is complete. */
- (void) bootWithCompletionBlock:(FSQBootBlock)block;

/** If the receiver has not completed booting queues the block to run when boot is finished. Otherwise runs the block immediately. */
- (void) onComplete:(FSQBootBlock)block;

- (void) addError:(NSError *)error;

@end
