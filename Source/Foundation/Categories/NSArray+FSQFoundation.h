//
//  NSArray+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 7/18/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

// In general, these extensions will be eclipsed if the version of NSArray for iPhone
// begins to support filtering with NSPredicate

#import <Foundation/Foundation.h>

@interface NSArray (FSQFoundation)

// Sorting

- (NSArray *) filteredArrayOnItemDescriptionContains:(NSString *)aDescription;
- (NSArray *) filteredArrayOnItemDescriptionStartsWith:(NSString *)aDescription;
- (NSArray *) filteredArrayOnAttribute:(NSString *)attributeNamed contains:(NSString *)aValue;
- (NSArray *) filteredArrayOnAttribute:(NSString *)attributeNamed startsWith:(NSString *)aValue;
- (NSArray *) filteredArrayOnAttribute:(NSString *)attributeNamed isEqual:(id)aValue;
- (NSArray *) sortedArrayUsingKey:(NSString *)sortKey ascending:(BOOL)ascending;

// Strings

- (NSString *) toHtmlWithKeyPath:(NSString *)keypath;

// Querying

- (id) objectMatchingPredicate:(NSPredicate *)predicate;
- (id) objectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

// Enumeration


- (NSArray *) collect:(id(^)(id obj))enumerationBlock;

- (NSArray *) flatten;
- (NSArray *) flatten:(id(^)(id obj))enumerationBlock;

@end

@interface NSMutableArray (FSQFoundation)

- (void) filterOnItemDescriptionContains:(NSString *)aDescription;
- (void) filterOnItemDescriptionStartsWith:(NSString *)aDescription;
- (void) filterOnAttribute:(NSString *)attributeNamed contains:(NSString *)aValue;
- (void) filterOnAttribute:(NSString *)attributeNamed startsWith:(NSString *)aValue;
- (void) filterOnAttribute:(NSString *)attributeNamed isEqual:(id)aValue;

- (void)sortUsingKey:(NSString *)sortKey ascending:(BOOL)ascending;


@end
