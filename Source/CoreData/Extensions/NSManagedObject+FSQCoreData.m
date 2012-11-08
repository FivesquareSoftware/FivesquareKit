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
#import "FSQLogging.h"

@implementation NSManagedObject (FSQCoreData)

// ========================================================================== //

#pragma mark - Properties



+ (NSString *) entityName {
	return [self className];
}

+ (NSEntityDescription *) entityInContext:(NSManagedObjectContext *)context {
	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

- (NSDictionary *) attributes {
	NSMutableDictionary *attributes = [NSMutableDictionary new];
	NSDictionary *propertiesByName = [[self entity] propertiesByName];
	for (NSString *key in propertiesByName) {
		id propertyDescription = [propertiesByName objectForKey:key];
		if ([propertyDescription isKindOfClass:[NSAttributeDescription class]]) {
			id value = [self valueForKeyPath:key error:NULL];
			if (value) {
				[attributes setValue:value forKey:key];
			}
		}
	}
	return attributes;
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
	
	NSDictionary *requestOptions = @{@"fetchBatchSize": @1};
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
	[requestOptions setObject:@1 forKey:@"fetchBatchSize"];
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
	__block id found = [self firstWithPredicate:predicate inContext:context];
	if(found == nil) {
		[context performBlockAndWait:^{
			found = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
		}];
	}
	[found updateWithObject:someAttributes merge:YES];
	return found;
}

+ (id) findOrCreateWithFetchRequestTemplate:(NSString *)templateName
			  substitutionVariables:(NSDictionary *)variables
					  attributes:(id)someAttributes
					   inContext:(NSManagedObjectContext *)context {
	__block id found = [self firstWithFetchRequestTemplate:templateName substitutionVariables:variables inContext:context];
	if(found == nil) {
		[context performBlockAndWait:^{
			found = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
		}];
	}
	[found updateWithObject:someAttributes merge:YES];
	return found;
}

+ (id) createInContext:(NSManagedObjectContext *)context {
	return [self createWithAttributes:nil inContext:context];
}

+ (id) createWithAttributes:(NSDictionary *)someAttributes
				  inContext:(NSManagedObjectContext *)context {
	
	__block id created;
	[context performBlockAndWait:^{
		created = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
	}];

	[created updateWithObject:someAttributes merge:NO];
	return created;
}



// ========================================================================== //

#pragma mark - Delete Methods


+ (BOOL) deleteAllInContext:(NSManagedObjectContext *)context {
	return [self deleteAllWithPredicate:nil inContext:context];
}

+ (BOOL) deleteAllWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
	NSMutableDictionary *requestOptions = [NSMutableDictionary dictionary];
	[requestOptions setObject:@(NO) forKey:@"includesPropertyValues"];
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


- (BOOL) updateWithAttributes:(NSDictionary *)attributes {
	return [self updateWithObject:attributes merge:YES];
}

- (BOOL) updateWithObject:(NSObject *)source merge:(BOOL)merge {
	NSDictionary *attributes = [[self entity] propertiesByName];
	for (NSString *key in attributes) {
		id propertyDescription = [attributes objectForKey:key];
		if ([propertyDescription isKindOfClass:[NSAttributeDescription class]]) {
			id value = [source valueForKeyPath:key error:NULL];
			if (value == [NSNull null]) {
				value = nil;
			}
			[self setValue:value forKey:key];
		}
		else if ([propertyDescription isKindOfClass:[NSRelationshipDescription class]]) {
			NSEntityDescription *destinationEntity = [propertyDescription destinationEntity];
			if ([propertyDescription isToMany]) {
				id<NSObject, NSFastEnumeration> collection = [source valueForKey:key];
				if (NO == [collection conformsToProtocol:@protocol(NSFastEnumeration)]) {
					continue; // we can't map to-many unless there is a collection
				}
				NSMutableSet *newObjects = [NSMutableSet set];
				for (id value in collection) {
					id ref = [value valueForKeyPath:@"<ref>" error:NULL];
					if (ref) {
						NSPredicate *predicate = [NSPredicate predicateWithFormat:ref];
						Class destinationClass = NSClassFromString([destinationEntity managedObjectClassName]);
						NSManagedObject *fetchedObject = [destinationClass firstWithPredicate:predicate inContext:self.managedObjectContext];
						[newObjects addObject:fetchedObject];
					}
					else if ([value isKindOfClass:[NSManagedObject class]]) {
						[newObjects addObject:value];
					}
					else {
						NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:[destinationEntity name] inManagedObjectContext:self.managedObjectContext];
						[newObject updateWithObject:value merge:merge];
						[newObjects addObject:newObject];
					}
				}
				if (merge) {
					// call add object on the relationship
					NSMutableSet *mutableDestinationSet = [self mutableSetValueForKey:key];
					[mutableDestinationSet addObjectsFromArray:[newObjects allObjects]];
				} 
				else {
					[self setValue:newObjects forKey:key];
				}
			} 
			else {
				id value = [source valueForKeyPath:key error:NULL];
				if (value == [NSNull null]) {
					value = nil;
				}

				id ref = [value valueForKeyPath:@"<ref>" error:NULL];
				if (ref) {
					NSPredicate *predicate = [NSPredicate predicateWithFormat:ref];
					Class destinationClass = NSClassFromString([destinationEntity managedObjectClassName]);
					NSManagedObject *fetchedObject = [destinationClass firstWithPredicate:predicate inContext:self.managedObjectContext];
					[self setValue:fetchedObject forKey:key];
				}
				else if ([value isKindOfClass:[NSManagedObject class]]) {
					[self setValue:value forKey:key];
				}
				else if (value) {
					NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:[destinationEntity name] inManagedObjectContext:self.managedObjectContext];
					[newObject updateWithObject:value merge:merge];
					[self setValue:newObject forKey:key];
				}
				else {
					[self setValue:value forKey:key];
				}
			}
		}
	}
	return YES;
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
			fetchRequest = [[managedObjectModel fetchRequestFromTemplateWithName:requestName substitutionVariables:variables] copy];
		} else {
			fetchRequest = [[managedObjectModel fetchRequestTemplateForName:requestName] copy];
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
