//
//  FSQKeychain.m
//  FivesquareKit
//
//  Created by John Clayton on 4/26/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQKeychain.h"

#import "FSQLogging.h"
#import "FSQAsserter.h"

@interface FSQKeychain ()
#if TARGET_OS_IPHONE
+ (NSMutableDictionary *) keychainItemForQuery:(NSDictionary *)keychainQuery;
+ (void) saveKeychainItem:(NSMutableDictionary *)keychainItem matchingQuery:(NSDictionary *)aQuery;
+ (NSMutableDictionary *) fetchItemDataForItemOfClass:(id)itemClass withAttributes:(NSDictionary *)attributes;
#endif
@end

@implementation FSQKeychain

#if TARGET_OS_IPHONE

+ (NSString *) passwordForIdentifier:(NSString *)identifier {
	NSMutableDictionary *genericAttrQuery = [[NSMutableDictionary alloc] init];
	
	[genericAttrQuery setObject:(id)objc_unretainedObject(kSecClassGenericPassword) forKey:(id)objc_unretainedObject(kSecClass)];
	NSData *genericAttrData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
	[genericAttrQuery setObject:genericAttrData forKey:(id)objc_unretainedObject(kSecAttrGeneric)];
	[genericAttrQuery setObject:(id)objc_unretainedObject(kSecMatchLimitOne) forKey:(id)objc_unretainedObject(kSecMatchLimit)];
	[genericAttrQuery setObject:(id)kCFBooleanTrue forKey:(id)objc_unretainedObject(kSecReturnAttributes)];
	
	NSMutableDictionary *item = [self keychainItemForQuery:genericAttrQuery];
	
	return (NSString *)[item objectForKey:(id)objc_unretainedObject(kSecValueData)];
}

+ (void) savePassword:(NSString *)password forIdentifier:(NSString *)identifier {
	NSMutableDictionary *genericAttrQuery = [[NSMutableDictionary alloc] init];
	
	[genericAttrQuery setObject:(id)objc_unretainedObject(kSecClassGenericPassword) forKey:(id)objc_unretainedObject(kSecClass)];
	NSData *genericAttrData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
	[genericAttrQuery setObject:genericAttrData forKey:(id)objc_unretainedObject(kSecAttrGeneric)];
	[genericAttrQuery setObject:(id)objc_unretainedObject(kSecMatchLimitOne) forKey:(id)objc_unretainedObject(kSecMatchLimit)];
	[genericAttrQuery setObject:(id)kCFBooleanTrue forKey:(id)objc_unretainedObject(kSecReturnAttributes)];
	
	NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
	[keychainItem setObject:genericAttrData forKey:(id)objc_unretainedObject(kSecAttrGeneric)];
	[keychainItem setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)objc_unretainedObject(kSecValueData)];
	
	[self saveKeychainItem:keychainItem matchingQuery:genericAttrQuery];
	
}


// ========================================================================== //

#pragma mark -
#pragma mark Get/Save to Keychain


+ (NSMutableDictionary *) keychainItemForQuery:(NSDictionary *)keychainQuery {	
	OSStatus keychainErr = noErr;
	
//	NSMutableDictionary *outDictionary = nil;
	CFMutableDictionaryRef outDictionary = NULL;
	keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&outDictionary);
	
	if (keychainErr == errSecItemNotFound) {
		FLog(@"Keychain Item not found.");
		return nil;
	}
	if (keychainErr != noErr) {
		FSQAssert(NO,@"Error fetching Keychain Item (%d).",keychainErr);
		return nil;
	}
	
	id itemClass = [keychainQuery objectForKey:(id)objc_unretainedObject(kSecClass)];
	NSMutableDictionary *keychainDictionary = [self fetchItemDataForItemOfClass:itemClass withAttributes:(__bridge NSMutableDictionary *)outDictionary];
	
//	[outDictionary release];
	CFRelease(outDictionary);
	return keychainDictionary;
}

+ (void) saveKeychainItem:(NSMutableDictionary *)keychainItem matchingQuery:(NSDictionary *)aQuery {
	OSStatus keychainErr = noErr;
//	NSDictionary *attributes = nil;
	CFDictionaryRef attributes = NULL;
	keychainErr = SecItemCopyMatching((__bridge CFDictionaryRef)aQuery, (CFTypeRef *)&attributes);
	if (keychainErr == noErr) { // There is an existing keychain item => attributes
		FSQAssert([(__bridge NSDictionary *)attributes isKindOfClass:[NSDictionary class]], @"Keychain returned item of wrong class %@", [(__bridge NSDictionary *)attributes class]);
        NSMutableDictionary *foundItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)attributes];
		[foundItem setObject:[aQuery objectForKey:(id)objc_unretainedObject(kSecClass)] forKey:(id)objc_unretainedObject(kSecClass)];		
		
		keychainErr = SecItemUpdate((CFDictionaryRef)objc_unretainedPointer(foundItem),(CFDictionaryRef)objc_unretainedPointer(keychainItem));
        FSQAssert(keychainErr == noErr, @"Couldn't update the Keychain Item (%d).", keychainErr);
    } else { // Create a new keychain item
		[keychainItem setObject:[aQuery objectForKey:(id)objc_unretainedObject(kSecClass)] forKey:(id)objc_unretainedObject(kSecClass)];		
		keychainErr = SecItemAdd((CFDictionaryRef)objc_unretainedPointer(keychainItem),NULL);
        FSQAssert(keychainErr == noErr, @"Couldn't add the Keychain Item (%d).", keychainErr);
    }
//	[attributes release];
	CFRelease(attributes);
}

+ (NSMutableDictionary *) fetchItemDataForItemOfClass:(id)itemClass withAttributes:(NSDictionary *)attributes {
    NSMutableDictionary *keychainItem = [NSMutableDictionary
										 dictionaryWithDictionary:attributes];
	
    [keychainItem setObject:(id)kCFBooleanTrue forKey:(id)objc_unretainedObject(kSecReturnData)];
    [keychainItem setObject:(id)itemClass forKey:(id)objc_unretainedObject(kSecClass)];
	
//    NSData *itemData = nil;
	CFDataRef itemData = NULL;
    OSStatus keychainError = noErr; 
    keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&itemData);
    if(keychainError == noErr) {
		if([itemClass isEqual:(id)objc_unretainedObject(kSecClassGenericPassword)] || [itemClass isEqual:(id)objc_unretainedObject(kSecClassInternetPassword)]) {
			NSString *password = [[NSString alloc] initWithBytes:[(__bridge NSData *)itemData bytes]
														  length:[(__bridge NSData *)itemData length] encoding:NSUTF8StringEncoding];
			[keychainItem setObject:password forKey:(id)objc_unretainedObject(kSecValueData)];
		}
    } else {
		if (keychainError == errSecItemNotFound)
            NSAssert(NO, @"Nothing was found in the keychain.\n");
		else {
			NSAssert(NO, @"Serious error");
		}
	}
	
//    [itemData release];
	CFRelease(itemData);
    return keychainItem;
}


#endif


@end
