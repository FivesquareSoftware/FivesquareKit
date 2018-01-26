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
- (NSArray *) sortedArrayUsingKey:(NSString *)sortKey ascending:(BOOL)ascending;
- (NSArray *)sortedArrayUsingSelector:(SEL)comparator;
- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr;
- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr;
@end

@interface NSMutableSet (FSQFoundation)
- (id) popObject;
- (NSSet *) popObjects:(NSUInteger)count;
@end