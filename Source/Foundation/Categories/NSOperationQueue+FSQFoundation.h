//
//  NSOperationQueue+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 7/17/11.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (FSQFoundation)

- (void)addOperationRecursively:(NSOperation *)operation;

@end
