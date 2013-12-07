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

+ (BOOL) isEmpty:(id)obj; //< @returns YES if obj == nil || [obj count] == 0
+ (BOOL) isNotEmpty:(id)obj;


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

//#if __IPHONE_OS_VERSION_MIN_REQUIRED < 40000
//- (id) firstObject; ///< @returns the first object if there is one, or nil.
//#endif

- (id) anyObject;
- (NSArray *) anyArray:(NSUInteger)seed;

- (id) meanObject;

/** Accesses objects in multidimensional arrays by index path. */
- (id) objectAtIndexPath:(NSIndexPath *)indexPath;

// Enumeration


- (NSArray *) collect:(id(^)(id obj))enumerationBlock;

- (NSArray *) flatten;
- (NSArray *) flatten:(id(^)(id obj))enumerationBlock;

- (NSArray *) objectsToIndex:(NSUInteger)index;
- (NSIndexPath *) indexPathForObject:(id)object;
- (NSArray *) firstObjects:(NSUInteger)length;

@end

@interface NSMutableArray (FSQFoundation)

- (void) filterOnItemDescriptionContains:(NSString *)aDescription;
- (void) filterOnItemDescriptionStartsWith:(NSString *)aDescription;
- (void) filterOnAttribute:(NSString *)attributeNamed contains:(NSString *)aValue;
- (void) filterOnAttribute:(NSString *)attributeNamed startsWith:(NSString *)aValue;
- (void) filterOnAttribute:(NSString *)attributeNamed isEqual:(id)aValue;

- (void)sortUsingKey:(NSString *)sortKey ascending:(BOOL)ascending;

- (id) shift;
- (id) pop;
- (void) insert:(id)object;


@end
