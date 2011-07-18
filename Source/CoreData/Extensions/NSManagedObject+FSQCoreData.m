//
//  NSManagedObject+FSQCoreData.m
//  FivesquareKit
//
//  Created by John Clayton on 2/21/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "NSManagedObject+FSQCoreData.h"

#import <objc/runtime.h>
#import "NSObject+FSQFoundation.h"
#import "FSQAsserter.h"

@implementation NSManagedObject (FSQCoreData)

// ========================================================================== //

#pragma mark - Properties



+ (NSString *) entityName {
	return [self className];
}

+ (NSEntityDescription *) entityInContext:(NSManagedObjectContext *)aContext {
	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:aContext];
}


// ========================================================================== //

#pragma mark - Fetch Request Template Methods



#pragma mark -- First

+ (id) firstWithFetchRequest:(NSString *)requestName 
				   inContext:(NSManagedObjectContext *)aContext {
	return [self firstWithFetchRequestTemplate:requestName substitutionVariables:nil sortDescriptors:nil inContext:aContext];
}

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables
						   inContext:(NSManagedObjectContext *)aContext {
	return [self firstWithFetchRequestTemplate:templateName substitutionVariables:variables sortDescriptors:nil inContext:aContext];
}

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables
					 sortDescriptors:(NSArray *)sortDescriptors
						   inContext:(NSManagedObjectContext *)aContext {
	
	NSDictionary *requestOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"fetchBatchSize"];
	NSFetchRequest *fetchRequest = [self fetchRequestNamed:templateName substitutionVariables:variables options:requestOptions inContext:aContext];
										
	id found = nil;
	
	NSError __block *error = nil;
	NSArray __block *results = nil;
	
	[aContext performBlockAndWait:^{
		NSError __autoreleasing *localError = nil;
		results = [aContext executeFetchRequest:fetchRequest error:&localError];
		if (localError) {
			error = localError;
		}
	}];
	
	if([results count] > 0) {
		found = [results objectAtIndex:0];
	}
	FSQAssert(error == nil, @"Error fetching first for fetchRequest %@ %@ (%@)",fetchRequest, [error localizedDescription], [error userInfo]);

	return found;
}

#pragma mark -- All


+ (id) allWithFetchRequest:(NSString *)requestName
				 inContext:(NSManagedObjectContext *)aContext {
	return [self allWithFetchRequestTemplate:requestName substitutionVariables:nil sortDescriptors:nil inContext:aContext];
}

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(NSDictionary *)variables
						 inContext:(NSManagedObjectContext *)aContext {
	return [self allWithFetchRequestTemplate:templateName substitutionVariables:variables sortDescriptors:nil inContext:aContext];
}

+ (id) allWithFetchRequestTemplate:(NSString *)templateName
			 substitutionVariables:(NSDictionary *)variables
				   sortDescriptors:(NSArray *)sortDescriptors
						 inContext:(NSManagedObjectContext *)aContext {
	
	NSFetchRequest *fetchRequest = [self fetchRequestNamed:templateName substitutionVariables:variables options:nil inContext:aContext];

	
	NSError __block *error = nil;
	NSArray __block *results = nil;
	
	[aContext performBlockAndWait:^{
		NSError __autoreleasing *localError = nil;
		results = [aContext executeFetchRequest:fetchRequest error:&localError];
		if (localError) {
			error = localError;
		}
	}];
	FSQAssert(error == nil, @"Error fetching all for fetchRequest %@ %@ (%@)",fetchRequest, [error localizedDescription], [error userInfo]);
	return results;
	

}


// ========================================================================== //

#pragma mark - Predicate Methods


#pragma mark -- First


+ (id) firstInContext:(NSManagedObjectContext *)aContext {
	return [self firstWithPredicate:nil inContext:aContext];	
}

+ (id) firstWithPredicate:(NSPredicate *)aPredicate
				inContext:(NSManagedObjectContext *)aContext {
	return [self firstWithPredicate:aPredicate sortDescriptors:nil inContext:aContext];
}

+ (id) firstWithPredicate:(NSPredicate *)aPredicate
		  sortDescriptors:(NSArray *)sortDescriptors
				inContext:(NSManagedObjectContext *)aContext {
	return [self firstWithPredicate:aPredicate sortDescriptors:sortDescriptors requestOptions:nil inContext:aContext];
}	

+ (id) firstWithPredicate:(NSPredicate *)aPredicate
		  sortDescriptors:(NSArray *)sortDescriptors
		   requestOptions:(NSDictionary *)someOptions
				inContext:(NSManagedObjectContext *)aContext {
	
	NSMutableDictionary *requestOptions = [NSMutableDictionary dictionary];
	if(aPredicate) {
		[requestOptions setObject:aPredicate forKey:@"predicate"];
	}
	if(sortDescriptors) {
		[requestOptions setObject:sortDescriptors forKey:@"sortDescriptors"];
	}
	[requestOptions setObject:[NSNumber numberWithInt:1] forKey:@"fetchBatchSize"];
	[requestOptions addEntriesFromDictionary:someOptions];

	NSFetchRequest *fetchRequest = [self fetchRequestNamed:nil substitutionVariables:nil options:requestOptions inContext:aContext];

	
	id found = nil;
	
	NSError __block *error = nil;
	NSArray __block *results = nil;
	
	[aContext performBlockAndWait:^{
		NSError __autoreleasing *localError = nil;
		results = [aContext executeFetchRequest:fetchRequest error:&localError];
		if (localError) {
			error = localError;
		}
	}];
	if([results count] > 0) {
		found = [results objectAtIndex:0];
	}
	FSQAssert(error == nil, @"Error fetching first for fetchRequest %@ %@ (%@)",fetchRequest, [error localizedDescription], [error userInfo]);
	
	return found;
}


#pragma mark -- All

+ (id) allInContext:(NSManagedObjectContext *)aContext {
	return [self allWithPredicate:nil inContext:aContext];
}

+ (id) allWithPredicate:(NSPredicate *)aPredicate 
			  inContext:(NSManagedObjectContext *)aContext {
	return [self allWithPredicate:aPredicate sortDescriptors:nil inContext:aContext];
}

+ (id) allWithPredicate:(NSPredicate *)aPredicate 
		sortDescriptors:(NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)aContext {
	return [self allWithPredicate:aPredicate sortDescriptors:sortDescriptors requestOptions:nil inContext:aContext];
}

+ (id) allWithPredicate:(NSPredicate *)aPredicate 
		sortDescriptors:(NSArray *)sortDescriptors
		 requestOptions:(NSDictionary *)someOptions
						inContext:(NSManagedObjectContext *)aContext {
	
	NSMutableDictionary *requestOptions = [NSMutableDictionary dictionary];
	if(aPredicate) {
		[requestOptions setObject:aPredicate forKey:@"predicate"];
	}
	if(sortDescriptors) {
		[requestOptions setObject:sortDescriptors forKey:@"sortDescriptors"];
	}
	[requestOptions addEntriesFromDictionary:someOptions];
	
	NSFetchRequest *fetchRequest = [self fetchRequestNamed:nil substitutionVariables:nil options:requestOptions inContext:aContext];
	
	
	NSError __block *error = nil;
	NSArray __block *results = nil;
	
	[aContext performBlockAndWait:^{
		NSError __autoreleasing *localError = nil;
		results = [aContext executeFetchRequest:fetchRequest error:&localError];
		if (localError) {
			error = localError;
		}
	}];
	FSQAssert(error == nil, @"Error fetching all for fetchRequest %@ %@ (%@)",fetchRequest, [error localizedDescription], [error userInfo]);
	return results;
}


// ========================================================================== //

#pragma mark - Factory Methods



+ (id) findOrCreateWithPredicate:(NSPredicate *)aPredicate 
					   inContext:(NSManagedObjectContext *)aContext {
	return [self findOrCreateWithPredicate:aPredicate attributes:nil inContext:aContext];
}

+ (id) findOrCreateWithPredicate:(NSPredicate *)aPredicate 
					  attributes:(NSDictionary *)someAttributes
					   inContext:(NSManagedObjectContext *)aContext {
	id found = [self firstWithPredicate:aPredicate inContext:aContext];
	if(found == nil) {
		found = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:aContext];
		for (NSString *key in someAttributes) {
			[found setValue:[someAttributes objectForKey:key] forKey:key];
		}
	}
	return found;
}

+ (id) createInContext:(NSManagedObjectContext *)aContext {
	return [self createWithAttributes:nil inContext:aContext];
}

+ (id) createWithAttributes:(NSDictionary *)someAttributes
				  inContext:(NSManagedObjectContext *)aContext {
	id created = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:aContext];
	for (NSString *key in someAttributes) {
		[created setValue:[someAttributes objectForKey:key] forKey:key];
	}
	return created;
}


// ========================================================================== //

#pragma mark - Update Methods


- (void) updateWithAttributes:(NSDictionary *)attributes {
	for (NSString *key in attributes) {
		id value = [attributes valueForKey:key];
		if(class_getProperty([self class], [key UTF8String])) {
			[self setValue:value forKey:key];
		}
	}
} 


// ========================================================================== //

#pragma mark - Fetch Request Builders


+ (NSFetchRequest *) fetchRequestInContext:(NSManagedObjectContext *)aContext {
	return [self fetchRequestNamed:nil substitutionVariables:nil options:nil inContext:aContext];
}


+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
							 inContext:(NSManagedObjectContext *)aContext {
	return [self fetchRequestNamed:requestName substitutionVariables:nil options:nil inContext:aContext];
}


+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
				 substitutionVariables:(NSDictionary *)variables 
							   options:(NSDictionary *)requestOptions
							 inContext:(NSManagedObjectContext *)aContext {
	NSFetchRequest *fetchRequest = nil; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:aContext];
	NSManagedObjectModel *managedObjectModel = [entity managedObjectModel];
	if(requestName) {
		if(variables) {
			fetchRequest = [managedObjectModel fetchRequestFromTemplateWithName:requestName substitutionVariables:variables];
		} else {
			fetchRequest = [managedObjectModel fetchRequestTemplateForName:requestName];
		}
	} else {
		fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
	}
	
	for (NSString *key in requestOptions) {
		id value = [requestOptions objectForKey:key];
		[fetchRequest setValue:value forKey:key];
	}
	
	return fetchRequest;
}



@end
