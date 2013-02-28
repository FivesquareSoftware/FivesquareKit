//
//  FSQUserDefaults.h
//  FivesquareKit
//
//  Created by John Clayton on 1/30/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif



// Compatibility

@protocol NSUserDefaultsProxy

- (id)objectForKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;

- (NSString *)stringForKey:(NSString *)defaultName;
- (NSArray *)arrayForKey:(NSString *)defaultName;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
- (NSData *)dataForKey:(NSString *)defaultName;
- (NSArray *)stringArrayForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;
- (NSURL *)URLForKey:(NSString *)defaultName;

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName;

@end


@interface FSQUserDefaults : NSObject <NSUserDefaultsProxy>

@property (nonatomic, strong) NSDictionary *defaultKeysAndValues; ///< THe plist values the receiver was initiialized with
@property (nonatomic, strong) NSMutableSet *changedKeys; ///< Any keys that have been set through the receiver, overriding their default values


+ (id) withDefaults:(NSString *)fileName; ///< Convenience

/** Initializes a new defaults object from a plist with the supplied name, preserving the default values found in the plist for comparisons.
 *  @param fileName - the name of a plist in the main bundle that holds keys and default values.
 */
- (id) initWithDefaults:(NSString *)fileName;

- (void) resetDefaults;
- (BOOL) valueWasSetForKey:(NSString *)key;
- (id) valueForKey:(NSString *)defaultsKey defaultValue:(id)defaultValue wasChanged:(BOOL *)wasChanged;

// Extensions

#if TARGET_OS_IPHONE
- (UIColor *) colorForKey:(NSString *)key;
- (void) setColor:(UIColor *)color forKey:(NSString *)key;
#else
- (NSColor *) colorForKey:(NSString *)key;
- (void) setColor:(NSColor *)color forKey:(NSString *)key;
#endif

#if TARGET_OS_IPHONE
- (UIColor *) colorFromHexStringForKey:(NSString *)key;
- (void) setHexStringForColor:(UIColor *)color forKey:(NSString *)key;
#else
- (NSColor *) colorFromHexStringForKey:(NSString *)key;
- (void) setHexStringForColor:(NSColor *)color forKey:(NSString *)key;
#endif

#if TARGET_OS_IPHONE
- (CGPoint) pointForKey:(NSString *)key;
- (void) setPoint:(CGPoint)point forKey:(NSString *)key;
#else
- (NSPoint) pointForKey:(NSString *)key;
- (void) setPoint:(NSPoint)point forKey:(NSString *)key;
#endif

- (id) archivedObjectForKey:(NSString *)key;
- (void) setArchivedObject:(id<NSCoding>)object forKey:(NSString *)key;

- (void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)defaultName;
- (NSUInteger)unsignedIntegerForKey:(NSString *)defaultName;


@end

