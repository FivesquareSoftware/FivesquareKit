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

+ (id) allWithPredicate:(NSPredicate *)predicate 
			  inContext:(NSManagedObjectContext *)context;

+ (id) allWithPredicate:(NSPredicate *)predicate 
		sortDescriptors:(NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)context;

+ (id) allWithPredicate:(NSPredicate *)predicate 
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

- (BOOL) updateWithAttributes:(NSDictionary *)attributes;

/** Will map object's values onto the receiver, recursing relationships and creating instances of those objects as necessary.
 * @param merge - if YES, will merge toMany properties rather than setting them
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
