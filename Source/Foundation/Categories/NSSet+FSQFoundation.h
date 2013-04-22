//
//  NSSet+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 9/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (FSQFoundation)

- (id) randomObject;
- (id) popObject;

@end

@interface NSMutableSet (FSQFoundation)
- (id) popObject;
- (NSSet *) popObjects:(NSUInteger)count;
@end