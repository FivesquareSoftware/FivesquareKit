//
//  NSManagedObject+FSQCoreData.h
//  FivesquareKit
//
//  Created by John Clayton on 2/21/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObject (FSQCoreData)


+ (NSString *) entityName;
+ (NSEntityDescription *) entityInContext:(NSManagedObjectContext *)context;


@property (nonatomic, readonly) NSDictionary *attributes; //< @returns just the non-entity, i.e. non-relationship, properties


/** @name Counters. 
 *  @{
 */

+ (NSUInteger) countInContext:(NSManagedObjectContext *)aContext NS_SWIFT_UNAVAILABLE("Use count(withPredicate:requestOptions:inContext:)");

+ (NSUInteger) countWithPredicate:(nullable NSPredicate *)aPredicate
						inContext:(NSManagedObjectContext *)aContext NS_SWIFT_UNAVAILABLE("Use count(withPredicate:requestOptions:inContext:)");

+ (NSUInteger) countWithPredicate:(nullable NSPredicate *)aPredicate
				   requestOptions:(nullable NSDictionary *)someOptions
						inContext:(NSManagedObjectContext *)aContext NS_SWIFT_NAME(count(withPredicate:requestOptions:inContext:));

/** @} */


/** @name Fetch request template finders. 
 *  @{
 */

+ (nullable instancetype) firstWithFetchRequest:(NSString *)requestName
				   inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use first(withFetchRequestTemplate:substitutionVariables:sortDescriptors:inContext:)");

+ (nullable instancetype) firstWithFetchRequestTemplate:(NSString *)templateName
			   substitutionVariables:(nullable NSDictionary *)variables
						   inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use first(withFetchRequestTemplate:substitutionVariables:sortDescriptors:inContext:)");

+ (nullable instancetype) firstWithFetchRequestTemplate:(NSString *)templateName
			   substitutionVariables:(nullable NSDictionary *)variables
					 sortDescriptors:(nullable NSArray *)sortDescriptors
						   inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(first(withFetchRequestTemplate:substitutionVariables:sortDescriptors:inContext:));

+ (id) allWithFetchRequest:(nullable NSString *)requestName
				 inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use all(withFetchRequestTemplate:substitutionVariables:sortDescriptors:inContext:)");

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(nullable NSDictionary *)variables
						 inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use all(withFetchRequestTemplate:substitutionVariables:sortDescriptors:inContext:)");

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(nullable NSDictionary *)variables
				   sortDescriptors:(nullable NSArray *)sortDescriptors
						 inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(all(withFetchRequestTemplate:substitutionVariables:sortDescriptors:inContext:));

/** @} */

/** @name Predicate finders. 
 *  @{
 */

+ (nullable instancetype) firstInContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use first(withPredicate:sortDescriptors:requestOptions:inContext:)");

+ (nullable instancetype) firstWithPredicate:(nullable NSPredicate *)predicate
				inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use first(withPredicate:sortDescriptors:requestOptions:inContext:)");

+ (nullable instancetype) firstWithPredicate:(nullable NSPredicate *)predicate
		  sortDescriptors:(nullable NSArray *)sortDescriptors
								   inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use first(withPredicate:sortDescriptors:requestOptions:inContext:)");

+ (nullable instancetype) firstWithPredicate:(nullable NSPredicate *)predicate
		  sortDescriptors:(nullable NSArray *)sortDescriptors
		   requestOptions:(nullable NSDictionary *)options
				inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(first(withPredicate:sortDescriptors:requestOptions:inContext:));


+ (id) allInContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use all(withPredicate:sortDescriptors:requestOptions:inContext:)");
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use allValues(forProperties:withPredicate:sortDescriptors:requestOptions:inContext:)");


+ (id) allWithPredicate:(nullable NSPredicate *)predicate
			  inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use all(withPredicate:sortDescriptors:requestOptions:inContext:)");
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch withPredicate:(nullable NSPredicate *)predicate
			  inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use allValues(forProperties:withPredicate:sortDescriptors:requestOptions:inContext:)");

+ (id) allWithPredicate:(nullable NSPredicate *)predicate
		sortDescriptors:(nullable NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use all(withPredicate:sortDescriptors:requestOptions:inContext:)");
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch withPredicate:(nullable NSPredicate *)predicate
		sortDescriptors:(nullable NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use allValues(forProperties:withPredicate:sortDescriptors:requestOptions:inContext:)");

+ (id) allWithPredicate:(nullable NSPredicate *)predicate
		sortDescriptors:(nullable NSArray *)sortDescriptors
				requestOptions:(nullable NSDictionary *)options
			  inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(all(withPredicate:sortDescriptors:requestOptions:inContext:));
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch withPredicate:(nullable NSPredicate *)predicate
		sortDescriptors:(nullable NSArray *)sortDescriptors
		 requestOptions:(nullable NSDictionary *)options
					inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(allValues(forProperties:withPredicate:sortDescriptors:requestOptions:inContext:));

/** @} */


/** @name Factory Methods. 
 *  @{
 */

+ (instancetype) findOrCreateWithPredicate:(nullable NSPredicate *)predicate
					   inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use findOrCreate(withPredicate:attributes:inContext:)");

+ (instancetype) findOrCreateWithPredicate:(nullable NSPredicate *)predicate
				  attributes:(nullable NSDictionary *)someAttributes
					   inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(findOrCreate(withPredicate:attributes:inContext:));

+ (instancetype) findOrCreateWithFetchRequestTemplate:(NSString *)templateName
					  substitutionVariables:(nullable NSDictionary *)variables
								  inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use findOrCreate(withFetchRequestTemplate:substitutionVariables:attributes:inContext:)");

+ (instancetype) findOrCreateWithFetchRequestTemplate:(NSString *)templateName
					  substitutionVariables:(nullable NSDictionary *)variables
								 attributes:(nullable id)someAttributes
								  inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(findOrCreate(withFetchRequestTemplate:substitutionVariables:attributes:inContext:));

+ (instancetype) createInContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use create(withAttributes:inContext:)");

+ (instancetype) createWithAttributes:(nullable NSDictionary *)someAttributes
				  inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(create(withAttributes:inContext:));

/** @} */

/** @name Delete methods 
 *  @{
 */

+ (BOOL) deleteAllInContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("Use deleteAll(withPredicate:inContext:)");

+ (BOOL) deleteAllWithPredicate:(nullable NSPredicate *)predicate inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(deleteAll(withPredicate:inContext:));

/** @} */


/** @name Update methods 
 *  @{
 */

/** @deprecated - @see updateWithObject:merge: instead. This method now simply calls that method with merge = YES. */
- (BOOL) updateWithAttributes:(NSDictionary *)attributes;

/** Will map object's values onto the receiver, recursing relationships and creating instances of those objects as necessary.
 * @param merge - if YES, will merge toMany properties rather than setting them
 * @returns YES if mapping was attempted, NO if attributes were nil
 * @note - We don't set attributes to nil values b/c we have no sure fire way of knowing if the source object actually responds to that key and would just return a spurios nil. If the value is NSNull however, the attribute is set to nil, with the assumption NSNull was deliberately set by the caller.
 */
- (BOOL) updateWithObject:(NSObject *)source merge:(BOOL)merge;

/** @} */


/** @name Primitive methods for building fetch requests. 
 *  @{
 */

+ (NSFetchRequest *) fetchRequestInContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("fetchRequest(named:substitutionVariables:options:inContext:)");

+ (NSFetchRequest *) fetchRequestNamed:(nullable NSString *)requestName
							 inContext:(NSManagedObjectContext *)context NS_SWIFT_UNAVAILABLE("fetchRequest(named:substitutionVariables:options:inContext:)");

+ (NSFetchRequest *) fetchRequestNamed:(nullable NSString *)requestName
				 substitutionVariables:(nullable NSDictionary *)variables
							   options:(nullable NSDictionary *)requestOptions
							 inContext:(NSManagedObjectContext *)context NS_SWIFT_NAME(fetchRequest(named:substitutionVariables:options:inContext:));

/** @} */


@end

NS_ASSUME_NONNULL_END
