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

+ (NSEntityDescription *) entityInContext:(NSManagedObjectContext *)context {
	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}


// ========================================================================== //

#pragma mark - Counters


+ (NSUInteger) countInContext:(NSManagedObjectContext *)context {
	return [self countWithPredicate:nil requestOptions:nil inContext:context];
}

+ (NSUInteger) countWithPredicate:(NSPredicate *)predicate
						inContext:(NSManagedObjectContext *)context {
	return [self countWithPredicate:predicate requestOptions:nil inContext:context];
}

+ (NSUInteger) countWithPredicate:(NSPredicate *)predicate
				   requestOptions:(NSDictionary *)options
						inContext:(NSManagedObjectContext *)context {
	
	NSMutableDictionary *requestOptions = [NSMutableDictionary dictionary];
	if(predicate) {
		[requestOptions setObject:predicate forKey:@"predicate"];
	}
	[requestOptions addEntriesFromDictionary:options];
	
	NSFetchRequest *fetchRequest = [self fetchRequestNamed:nil substitutionVariables:nil options:requestOptions inContext:context];
	
	__block NSError *error = nil;
	__block NSUInteger count = 0;
	
	[context performBlockAndWait:^{
		__autoreleasing NSError *localError = nil;
		count = [context countForFetchRequest:fetchRequest error:&localError];
		if (localError) {
			error = localError;
		}
	}];
	
	FSQAssert(error == nil, @"Error counting for fetchRequest %@ %@ (%@)",fetchRequest, [error localizedDescription], [error userInfo]);
	return count;
}


// ========================================================================== //

#pragma mark - Fetch Request Template Methods



#pragma mark -- First

+ (id) firstWithFetchRequest:(NSString *)requestName 
				   inContext:(NSManagedObjectContext *)context {
	return [self firstWithFetchRequestTemplate:requestName substitutionVariables:nil sortDescriptors:nil inContext:context];
}

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables 
						   inContext:(NSManagedObjectContext *)context {
	return [self firstWithFetchRequestTemplate:templateName substitutionVariables:variables sortDescriptors:nil inContext:context];
}

+ (id) firstWithFetchRequestTemplate:(NSString *)templateName 
			   substitutionVariables:(NSDictionary *)variables 
					 sortDescriptors:(NSArray *)sortDescriptors 
						   inContext:(NSManagedObjectContext *)context {
	
	NSDictionary *requestOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"fetchBatchSize"];
	NSFetchRequest *fetchRequest = [self fetchRequestNamed:templateName substitutionVariables:variables options:requestOptions inContext:context];
										
	id found = nil;
	
	__block NSError *error = nil;
	__block NSArray *results = nil;
	
	[context performBlockAndWait:^{
		__autoreleasing NSError *localError = nil;
		results = [context executeFetchRequest:fetchRequest error:&localError];
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
				 inContext:(NSManagedObjectContext *)context {
	return [self allWithFetchRequestTemplate:requestName substitutionVariables:nil sortDescriptors:nil inContext:context];
}

+ (id) allWithFetchRequestTemplate:(NSString *)templateName 
			 substitutionVariables:(NSDictionary *)variables 
						 inContext:(NSManagedObjectContext *)context {
	return [self allWithFetchRequestTemplate:templateName substitutionVariables:variables sortDescriptors:nil inContext:context];
}

+ (id) allWithFetchRequestTemplate:(NSString *)templateName 
			 substitutionVariables:(NSDictionary *)variables 
				   sortDescriptors:(NSArray *)sortDescriptors 
						 inContext:(NSManagedObjectContext *)context {
	
	NSFetchRequest *fetchRequest = [self fetchRequestNamed:templateName substitutionVariables:variables options:nil inContext:context];

	
	__block NSError *error = nil;
	__block NSArray *results = nil;
	
	[context performBlockAndWait:^{
		__autoreleasing NSError *localError = nil;
		results = [context executeFetchRequest:fetchRequest error:&localError];
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


+ (id) firstInContext:(NSManagedObjectContext *)context {
	return [self firstWithPredicate:nil inContext:context];	
}

+ (id) firstWithPredicate:(NSPredicate *)predicate
				inContext:(NSManagedObjectContext *)context {
	return [self firstWithPredicate:predicate sortDescriptors:nil inContext:context];
}

+ (id) firstWithPredicate:(NSPredicate *)predicate
		  sortDescriptors:(NSArray *)sortDescriptors
				inContext:(NSManagedObjectContext *)context {
	return [self firstWithPredicate:predicate sortDescriptors:sortDescriptors requestOptions:nil inContext:context];
}	

+ (id) firstWithPredicate:(NSPredicate *)predicate
		  sortDescriptors:(NSArray *)sortDescriptors
		   requestOptions:(NSDictionary *)options
				inContext:(NSManagedObjectContext *)context {
	
	NSMutableDictionary *requestOptions = [NSMutableDictionary dictionary];
	if(predicate) {
		[requestOptions setObject:predicate forKey:@"predicate"];
	}
	if(sortDescriptors) {
		[requestOptions setObject:sortDescriptors forKey:@"sortDescriptors"];
	}
	[requestOptions setObject:[NSNumber numberWithInt:1] forKey:@"fetchBatchSize"];
	[requestOptions addEntriesFromDictionary:options];

	NSFetchRequest *fetchRequest = [self fetchRequestNamed:nil substitutionVariables:nil options:requestOptions inContext:context];

	
	id found = nil;
	
	__block NSError *error = nil;
	__block NSArray *results = nil;
	
	[context performBlockAndWait:^{
		__autoreleasing NSError *localError = nil;
		results = [context executeFetchRequest:fetchRequest error:&localError];
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

+ (id) allInContext:(NSManagedObjectContext *)context {
	return [self allWithPredicate:nil inContext:context];
}

+ (id) allWithPredicate:(NSPredicate *)predicate 
			  inContext:(NSManagedObjectContext *)context {
	return [self allWithPredicate:predicate sortDescriptors:nil inContext:context];
}

+ (id) allWithPredicate:(NSPredicate *)predicate 
		sortDescriptors:(NSArray *)sortDescriptors
			  inContext:(NSManagedObjectContext *)context {
	return [self allWithPredicate:predicate sortDescriptors:sortDescriptors requestOptions:nil inContext:context];
}

+ (id) allWithPredicate:(NSPredicate *)predicate 
		sortDescriptors:(NSArray *)sortDescriptors
		 requestOptions:(NSDictionary *)options
						inContext:(NSManagedObjectContext *)context {
	
	NSMutableDictionary *requestOptions = [NSMutableDictionary dictionary];
	if(predicate) {
		[requestOptions setObject:predicate forKey:@"predicate"];
	}
	if(sortDescriptors) {
		[requestOptions setObject:sortDescriptors forKey:@"sortDescriptors"];
	}
	[requestOptions addEntriesFromDictionary:options];
	
	NSFetchRequest *fetchRequest = [self fetchRequestNamed:nil substitutionVariables:nil options:requestOptions inContext:context];
	
	
	__block NSError *error = nil;
	__block NSArray *results = nil;
	
	[context performBlockAndWait:^{
		__autoreleasing NSError *localError = nil;
		results = [context executeFetchRequest:fetchRequest error:&localError];
		if (localError) {
			error = localError;
		}
	}];
	FSQAssert(error == nil, @"Error fetching all for fetchRequest %@ %@ (%@)",fetchRequest, [error localizedDescription], [error userInfo]);
	return results;
}


// ========================================================================== //

#pragma mark - Factory Methods



+ (id) findOrCreateWithPredicate:(NSPredicate *)predicate 
					   inContext:(NSManagedObjectContext *)context {
	return [self findOrCreateWithPredicate:predicate attributes:nil inContext:context];
}

+ (id) findOrCreateWithPredicate:(NSPredicate *)predicate 
					  attributes:(NSDictionary *)someAttributes
					   inContext:(NSManagedObjectContext *)context {
	id found = [self firstWithPredicate:predicate inContext:context];
	if(found == nil) {
		found = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
		for (NSString *key in someAttributes) {
			[found setValue:[someAttributes objectForKey:key] forKey:key];
		}
	}
	return found;
}

+ (id) createInContext:(NSManagedObjectContext *)context {
	return [self createWithAttributes:nil inContext:context];
}

+ (id) createWithAttributes:(NSDictionary *)someAttributes
				  inContext:(NSManagedObjectContext *)context {
	id created = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
	for (NSString *key in someAttributes) {
		[created setValue:[someAttributes objectForKey:key] forKey:key];
	}
	return created;
}



// ========================================================================== //

#pragma mark - Delete Methods


+ (BOOL) deleteAllInContext:(NSManagedObjectContext *)context {
	return [self deleteAllWithPredicate:nil inContext:context];
}

+ (BOOL) deleteAllWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
	NSMutableDictionary *requestOptions = [NSMutableDictionary dictionary];
	[requestOptions setObject:[NSNumber numberWithBool:NO] forKey:@"includesPropertyValues"];
	if(predicate) {
		[requestOptions setObject:predicate forKey:@"predicate"];
	}

	NSFetchRequest *fetchRequest= [self fetchRequestNamed:nil substitutionVariables:nil options:requestOptions inContext:context];
	
	__block NSError *error = nil;
	__block NSArray *results = nil;
	[context performBlockAndWait:^{
		__autoreleasing NSError *localError = nil;
		results = [context executeFetchRequest:fetchRequest error:&localError];
		if (localError) {
			error = localError;
		}
	}];
	FSQAssert(error == nil, @"Error fetching for deletion %@ %@ (%@)",fetchRequest, [error localizedDescription], [error userInfo]);
	if (error) {
		return NO;
	}
	[context performBlockAndWait:^{
		for (NSManagedObject *found in results) {
			[context deleteObject:found];
		}
	}];
	return YES;
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


+ (NSFetchRequest *) fetchRequestInContext:(NSManagedObjectContext *)context {
	return [self fetchRequestNamed:nil substitutionVariables:nil options:nil inContext:context];
}


+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
							 inContext:(NSManagedObjectContext *)context {
	return [self fetchRequestNamed:requestName substitutionVariables:nil options:nil inContext:context];
}


+ (NSFetchRequest *) fetchRequestNamed:(NSString *)requestName 
				 substitutionVariables:(NSDictionary *)variables 
							   options:(NSDictionary *)requestOptions
							 inContext:(NSManagedObjectContext *)context {
	NSFetchRequest *fetchRequest = nil; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
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
