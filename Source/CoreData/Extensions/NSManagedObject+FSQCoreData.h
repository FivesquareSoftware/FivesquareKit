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
+ (NSEntityDescription *) entityInContext:(NSManagedObjectContext *)aContext;



/** @ Fetch request template methods. */

+ (id) firstWithFetchRequest:(NSString *)requestName 
				   inContext:(NSManagedObjectContext *)aContext;

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables
						   inContext:(NSManagedObjectContext *)aContext;

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables
					 sortDescriptors:(NSArray *)sortDescriptors
						   inContext:(NSManagedObjectContext *)aContext;

+ (id) allWithFetchRequest:(NSString *)requestName
				 inContext:(NSManagedObjectContext *)aContext;

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(NSDictionary *)variables
						 inContext:(NSManagedObjectContext *)aContext;

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(NSDictionary *)variables
				   sortDescriptors:(NSArray *)sortDescriptors
						 inContext:(NSManagedObjectContext *)aContext;


/** @ Predicate methods. */

+ (id) firstInContext:(NSManagedObjectContext *)aContext;

+ (id) firstWithPredicate:(NSPredicate *)aPredicate
				inContext:(NSManagedObjectContext *)aContext;

+ (id) firstWithPredicate:(NSPredicate *)aPredicate
		  sortDescriptors:(NSArray *)sortDescriptors
				inContext:(NSManagedObjectContext *)aContext;

+ (id) firstWithPredicate:(NSPredicate *)aPredicate
		  sortDescriptors:(NSArray *)sortDescriptors
		   requestOptions:(NSDictionary *)someOptions
				inContext:(NSManagedObjectContext *)aContext;


+ (id) allInContext:(NSManagedObjectContext *)aContext;

+ (id) allWithPredicate:(NSPredicate *)aPredicate 
			  inContext:(NSManagedObjectContext *)aContext;

+ (id) allWithPredicate:(NSPredicate *)aPredicate 
		sortDescriptors:(NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)aContext;

+ (id) allWithPredicate:(NSPredicate *)aPredicate 
		sortDescriptors:(NSArray *)sortDescriptors
				requestOptions:(NSDictionary *)someOptions
			  inContext:(NSManagedObjectContext *)aContext;


/** @ Factory Methods. */

+ (id) findOrCreateWithPredicate:(NSPredicate *)aPredicate 
					   inContext:(NSManagedObjectContext *)aContext;

+ (id) findOrCreateWithPredicate:(NSPredicate *)aPredicate 
				  attributes:(NSDictionary *)someAttributes
					   inContext:(NSManagedObjectContext *)aContext;

+ (id) createInContext:(NSManagedObjectContext *)aContext;

+ (id) createWithAttributes:(NSDictionary *)someAttributes
				  inContext:(NSManagedObjectContext *)aContext;


/** Update methods */

- (void) updateWithAttributes:(NSDictionary *)attributes;

/** Primitive methods for building fetch requests. */

+ (NSFetchRequest *) fetchRequestInContext:(NSManagedObjectContext *)aContext;

+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
							 inContext:(NSManagedObjectContext *)aContext;

+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
				 substitutionVariables:(NSDictionary *)variables 
							   options:(NSDictionary *)requestOptions
							 inContext:(NSManagedObjectContext *)aContext;

@end
