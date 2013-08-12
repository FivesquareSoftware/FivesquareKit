//
//  NSManagedObject+FSQCoreData.h
//  FivesquareKit
//
//  Created by John Clayton on 2/21/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NSManagedObject (FSQCoreData)


+ (NSString *) entityName;
+ (NSEntityDescription *) entityInContext:(NSManagedObjectContext *)context;


@property (nonatomic, readonly) NSDictionary *attributes; //< @returns just the non-entity, i.e. non-relationship, properties


/** @name Counters. 
 *  @{
 */

+ (NSUInteger) countInContext:(NSManagedObjectContext *)aContext;

+ (NSUInteger) countWithPredicate:(NSPredicate *)aPredicate
						inContext:(NSManagedObjectContext *)aContext;

+ (NSUInteger) countWithPredicate:(NSPredicate *)aPredicate
				   requestOptions:(NSDictionary *)someOptions
						inContext:(NSManagedObjectContext *)aContext;

/** @} */


/** @name Fetch request template finders. 
 *  @{
 */

+ (id) firstWithFetchRequest:(NSString *)requestName 
				   inContext:(NSManagedObjectContext *)context;

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables
						   inContext:(NSManagedObjectContext *)context;

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables
					 sortDescriptors:(NSArray *)sortDescriptors
						   inContext:(NSManagedObjectContext *)context;

+ (id) allWithFetchRequest:(NSString *)requestName
				 inContext:(NSManagedObjectContext *)context;

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(NSDictionary *)variables
						 inContext:(NSManagedObjectContext *)context;

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(NSDictionary *)variables
				   sortDescriptors:(NSArray *)sortDescriptors
						 inContext:(NSManagedObjectContext *)context;

/** @} */

/** @name Predicate finders. 
 *  @{
 */

+ (id) firstInContext:(NSManagedObjectContext *)context;

+ (id) firstWithPredicate:(NSPredicate *)predicate
				inContext:(NSManagedObjectContext *)context;

+ (id) firstWithPredicate:(NSPredicate *)predicate
		  sortDescriptors:(NSArray *)sortDescriptors
				inContext:(NSManagedObjectContext *)context;

+ (id) firstWithPredicate:(NSPredicate *)predicate
		  sortDescriptors:(NSArray *)sortDescriptors
		   requestOptions:(NSDictionary *)options
				inContext:(NSManagedObjectContext *)context;


+ (id) allInContext:(NSManagedObjectContext *)context;
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch inContext:(NSManagedObjectContext *)context;


+ (id) allWithPredicate:(NSPredicate *)predicate
			  inContext:(NSManagedObjectContext *)context;
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch withPredicate:(NSPredicate *)predicate
			  inContext:(NSManagedObjectContext *)context;

+ (id) allWithPredicate:(NSPredicate *)predicate
		sortDescriptors:(NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)context;
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch withPredicate:(NSPredicate *)predicate
		sortDescriptors:(NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)context;

+ (id) allWithPredicate:(NSPredicate *)predicate
		sortDescriptors:(NSArray *)sortDescriptors
				requestOptions:(NSDictionary *)options
			  inContext:(NSManagedObjectContext *)context;
+ (id) allValuesForProperties:(NSArray *)propertiesToFetch withPredicate:(NSPredicate *)predicate
		sortDescriptors:(NSArray *)sortDescriptors
		 requestOptions:(NSDictionary *)options
			  inContext:(NSManagedObjectContext *)context;

/** @} */


/** @name Factory Methods. 
 *  @{
 */

+ (id) findOrCreateWithPredicate:(NSPredicate *)predicate 
					   inContext:(NSManagedObjectContext *)context;

+ (id) findOrCreateWithPredicate:(NSPredicate *)predicate 
				  attributes:(NSDictionary *)someAttributes
					   inContext:(NSManagedObjectContext *)context;

+ (id) findOrCreateWithFetchRequestTemplate:(NSString *)templateName
					  substitutionVariables:(NSDictionary *)variables
								  inContext:(NSManagedObjectContext *)context;

+ (id) findOrCreateWithFetchRequestTemplate:(NSString *)templateName
					  substitutionVariables:(NSDictionary *)variables
								 attributes:(id)someAttributes
								  inContext:(NSManagedObjectContext *)context;

+ (id) createInContext:(NSManagedObjectContext *)context;

+ (id) createWithAttributes:(NSDictionary *)someAttributes
				  inContext:(NSManagedObjectContext *)context;

/** @} */

/** @name Delete methods 
 *  @{
 */

+ (BOOL) deleteAllInContext:(NSManagedObjectContext *)context;

+ (BOOL) deleteAllWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

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

+ (NSFetchRequest *) fetchRequestInContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
							 inContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
				 substitutionVariables:(NSDictionary *)variables 
							   options:(NSDictionary *)requestOptions
							 inContext:(NSManagedObjectContext *)context;

/** @} */


@end
