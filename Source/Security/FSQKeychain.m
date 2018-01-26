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
	
	[genericAttrQuery setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id) kSecClass];
	NSData *genericAttrData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
	[genericAttrQuery setObject:genericAttrData forKey:(__bridge id) kSecAttrGeneric];
	[genericAttrQuery setObject:(__bridge id) kSecMatchLimitOne forKey:(__bridge id) kSecMatchLimit];
	[genericAttrQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id) kSecReturnAttributes];
	
	NSMutableDictionary *item = [self keychainItemForQuery:genericAttrQuery];
	
	return (NSString *)[item objectForKey:(__bridge id) kSecValueData];
}

+ (void) savePassword:(NSString *)password forIdentifier:(NSString *)identifier {
	NSMutableDictionary *genericAttrQuery = [[NSMutableDictionary alloc] init];
	
	[genericAttrQuery setObject:(__bridge id) kSecClassGenericPassword forKey:(__bridge id) kSecClass];
	NSData *genericAttrData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
	[genericAttrQuery setObject:genericAttrData forKey:(__bridge id) kSecAttrGeneric];
	[genericAttrQuery setObject:(__bridge id) kSecMatchLimitOne forKey:(__bridge id) kSecMatchLimit];
	[genericAttrQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id) kSecReturnAttributes];
	
	NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
	[keychainItem setObject:genericAttrData forKey:(__bridge id) kSecAttrGeneric];
	[keychainItem setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id) kSecValueData];
	
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
	
	id itemClass = [keychainQuery objectForKey:(__bridge id) kSecClass];
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
		[foundItem setObject:[aQuery objectForKey:(__bridge id) kSecClass] forKey:(__bridge id) kSecClass];		
		
		keychainErr = SecItemUpdate((__bridge CFDictionaryRef)foundItem,(__bridge CFDictionaryRef)keychainItem);
        FSQAssert(keychainErr == noErr, @"Couldn't update the Keychain Item (%d).", keychainErr);
    } else { // Create a new keychain item
		[keychainItem setObject:[aQuery objectForKey:(__bridge id) kSecClass] forKey:(__bridge id) kSecClass];		
		keychainErr = SecItemAdd((__bridge CFDictionaryRef)keychainItem,NULL);
        FSQAssert(keychainErr == noErr, @"Couldn't add the Keychain Item (%d).", keychainErr);
    }
//	[attributes release];
	CFRelease(attributes);
}

+ (NSMutableDictionary *) fetchItemDataForItemOfClass:(id)itemClass withAttributes:(NSDictionary *)attributes {
    NSMutableDictionary *keychainItem = [NSMutableDictionary
										 dictionaryWithDictionary:attributes];
	
    [keychainItem setObject:(id)kCFBooleanTrue forKey:(__bridge id) kSecReturnData];
    [keychainItem setObject:(id)itemClass forKey:(__bridge id) kSecClass];
	
//    NSData *itemData = nil;
	CFDataRef itemData = NULL;
    OSStatus keychainError = noErr; 
    keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&itemData);
    if(keychainError == noErr) {
		if([itemClass isEqual:(__bridge id) kSecClassGenericPassword] || [itemClass isEqual:(__bridge id) kSecClassInternetPassword]) {
			NSString *password = [[NSString alloc] initWithBytes:[(__bridge NSData *)itemData bytes]
														  length:[(__bridge NSData *)itemData length] encoding:NSUTF8StringEncoding];
			[keychainItem setObject:password forKey:(__bridge id) kSecValueData];
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
