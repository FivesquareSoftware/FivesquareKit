//
//  NSArray+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 7/18/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import "NSArray+FSQFoundation.h"
#import "NSObject+FSQFoundation.h"



@implementation NSArray (FSQFoundation)


+ (BOOL) isEmpty:(id)obj {
	BOOL isEmpty = [NSObject isEmpty:obj];
	if (isEmpty) {
		return isEmpty;
	}
	
	return [obj count] == 0;
}

+ (BOOL) isNotEmpty:(id)obj {
	return NO == [self isEmpty:obj];
}



// ========================================================================== //

#pragma mark - Sorting



// Returns an autoreleased array with elements from the receiver that contain the description
- (NSArray *) filteredArrayOnItemDescriptionContains:(NSString *)aDescription; {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
	[filteredArray addObjectsFromArray:self];
    [filteredArray filterOnItemDescriptionContains:aDescription];
    return filteredArray;
}

// Returns an autoreleased array with elements from the receiver that start with the description
- (NSArray *) filteredArrayOnItemDescriptionStartsWith:(NSString *)aDescription {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
	[filteredArray addObjectsFromArray:self];
    [filteredArray filterOnItemDescriptionStartsWith:aDescription];
    return filteredArray;
}

- (NSArray *) filteredArrayOnAttribute:(NSString *)attributeNamed contains:(NSString *)aValue {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
	[filteredArray addObjectsFromArray:self];
    [filteredArray filterOnAttribute:attributeNamed contains:aValue];
    return filteredArray;
}

- (NSArray *) filteredArrayOnAttribute:(NSString *)attributeNamed startsWith:(NSString *)aValue {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
	[filteredArray addObjectsFromArray:self];
    [filteredArray filterOnAttribute:attributeNamed startsWith:aValue];
    return filteredArray;
}

- (NSArray *) filteredArrayOnAttribute:(NSString *)attributeNamed isEqual:(id)aValue {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
	[filteredArray addObjectsFromArray:self];
    [filteredArray filterOnAttribute:attributeNamed isEqual:aValue];
    return filteredArray;
}

- (NSArray *) sortedArrayUsingKey:(NSString *)sortKey ascending:(BOOL)ascending {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    NSArray *sortedArray = [self sortedArrayUsingDescriptors:@[descriptor]];
    return sortedArray;
}


// ========================================================================== //

#pragma mark - Strings



- (NSString *) toHtmlWithKeyPath:(NSString *)keypath {
    NSMutableString *listString = [NSMutableString stringWithString:@"<ul>"];
    for (id item in self) {
        [listString appendString:[NSString stringWithFormat:@"<li>%@</li>",[item valueForKeyPath:keypath]]];
    }
    [listString appendString:@"</ul>"];
    return listString;    
}

// ========================================================================== //

#pragma mark - Querying



- (id) objectMatchingPredicate:(NSPredicate *)predicate {
	return [[self filteredArrayUsingPredicate:predicate] lastObject];
}

- (id) objectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
	id object = nil;
	NSUInteger index  = [self indexOfObjectPassingTest:predicate];
	if (index != NSNotFound) {
		object = [self objectAtIndex:index];
	}
	return object;
}


//#if __IPHONE_OS_VERSION_MIN_REQUIRED < 40000
//- (id) firstObject {
//	if (self.count < 1) {
//		return nil;
//	}
//	return [self objectAtIndex:0];
//}
//#endif

- (id) anyObject {
	uint32_t rnd = arc4random_uniform((u_int32_t)[self count]);
    return [self objectAtIndex:rnd];
}

- (NSArray *) anyArray:(NSUInteger)count {
	NSMutableArray *array = [NSMutableArray new];
	while ([array count] < count) {
		[array addObject:[self anyObject]];
	}
	return array;
}

- (id) meanObject {
	if (self.count > 2) {
		NSUInteger meanIndex = self.count/2;
		id meanObject = self[meanIndex];
		return meanObject;
	}
	return [self firstObject];
}

- (id) objectAtIndexPath:(NSIndexPath *)indexPath {
	id object = self;
	NSUInteger length = [indexPath length];
	for (NSUInteger i = 0; i < length; i++) {
		NSUInteger index = [indexPath indexAtPosition:i];
		if (index < [object count]) {
			object = [object objectAtIndex:index];
		}
		else {
			object = nil;
		}
	}
	return object;
}

- (NSIndexPath *) indexPathForObject:(id)object {
	__block NSIndexPath *indexPath = [NSIndexPath new];
	[self enumerateObjectsUsingBlock:^(id child, NSUInteger idx, BOOL *stop) {
		if (object == child) {
			indexPath = [indexPath indexPathByAddingIndex:idx];
			*stop = YES;
		}
		else if ([child isKindOfClass:[NSArray class]]) {
			NSIndexPath *childIndexPath = [child indexPathForObject:object];
			NSUInteger length = [childIndexPath length];
			if (length > 0) {
				indexPath = [indexPath indexPathByAddingIndex:idx];
				NSUInteger *indexes = malloc(sizeof(NSUInteger)*length);
				[childIndexPath getIndexes:indexes];
				for (NSUInteger i = 0; i < length; i++) {
					indexPath = [indexPath indexPathByAddingIndex:indexes[i]];
				}
				free(indexes);
				*stop = YES;
			}
		}
	}];
	return indexPath;
}

// ========================================================================== //

#pragma mark - Enumeration


- (NSArray *) collect:(id(^)(id obj))enumerationBlock {
	if (nil == enumerationBlock) {
		return [self copy];
	}
	NSMutableArray *newArray = [NSMutableArray new];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id newObj = enumerationBlock(obj);
		if (obj) {
			[newArray addObject:newObj];
		}
	}];
	return newArray;
}

- (NSArray *) flatten {
	return [self flatten:nil];
}

- (NSArray *) flatten:(id(^)(id obj))enumerationBlock {
	NSMutableArray *newArray = [NSMutableArray new];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id newObj;
		if (enumerationBlock) {	
			newObj = enumerationBlock(obj);
		}
		else {
			newObj = obj;
		}
		if ([newObj isKindOfClass:[NSArray class]]) {
			[newArray addObjectsFromArray:[newObj flatten:enumerationBlock]];
		}
		else {
			[newArray addObject:newObj];
		}
	}];
	return newArray;
}

- (NSArray *) objectsToIndex:(NSUInteger)index {
	return [self firstObjects:index+1];
}

- (NSArray *) firstObjects:(NSUInteger)length {
	NSUInteger count = [self count];
	NSRange sliceRange = NSMakeRange(0, length);
	if (NSMaxRange(sliceRange) > count) {
		sliceRange.length = count;
	}
	NSArray *array = [self subarrayWithRange:sliceRange];
	return array;
}

@end


@implementation NSMutableArray (FSQFoundation)

// Filters the receiver in place on elements that contain the description
- (void) filterOnItemDescriptionContains:(NSString *)aDescription {
    [self filterOnAttribute:@"description" startsWith:aDescription];
}

// Filters the receiver in place on elements that start with the description
- (void) filterOnItemDescriptionStartsWith:(NSString *)aDescription {
    [self filterOnAttribute:@"description" contains:aDescription];
}

- (void) filterOnAttribute:(NSString *)attributeNamed contains:(NSString *)aValue {
	@autoreleasepool {
		NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"SELF.%@ CONTAINS[cd] %@", attributeNamed, aValue];
		[self filterUsingPredicate:predicateTemplate];
	}
}

- (void) filterOnAttribute:(NSString *)attributeNamed startsWith:(NSString *)aValue {
	@autoreleasepool {
		NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"SELF.%@ BEGINSWITH[cd] %@", attributeNamed, aValue];
		[self filterUsingPredicate:predicateTemplate];
	}
}

- (void) filterOnAttribute:(NSString *)attributeNamed isEqual:(id)aValue {
	@autoreleasepool {
		NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"SELF.%@ = %@", attributeNamed, aValue];
		[self filterUsingPredicate:predicateTemplate];
	}
}

- (void)sortUsingKey:(NSString *)sortKey ascending:(BOOL)ascending {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    [self sortUsingDescriptors:@[descriptor]];
}

- (id) shift {
	id firstObject = [self firstObject];
	if (firstObject) {
		[self removeObject:firstObject];
	}
	return firstObject;
}

- (id) pop {
	id lastObject = [self lastObject];
	if (lastObject) {
		[self removeObject:lastObject];
	}
	return lastObject;
}

- (void) insert:(id)object {
	[self insertObject:object atIndex:0];
}

@end



