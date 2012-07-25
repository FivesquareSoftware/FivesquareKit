//
//  FSQUserDefaults.m
//  FivesquareKit
//
//  Created by John Clayton on 1/30/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQUserDefaults.h"


#import "FSQMacros.h"


#define StandardDefaults() [NSUserDefaults standardUserDefaults]


@interface FSQUserDefaults ()
@property (nonatomic, strong) NSMutableDictionary *typesForKeys;
@end

@implementation FSQUserDefaults

// ========================================================================== //

#pragma mark - Properties


FSQ_SYNTHESIZE(defaultsKeysAndValues)
FSQ_SYNTHESIZE(changedKeys)


+ (id) withDefaults:(NSString *)name {
	return [[self alloc] initWithDefaults:name];
}

- (id) initWithDefaults:(NSString *)name {
    self = [super init];
    if (self) {
		NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
		NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
		if(defaults) {
			[StandardDefaults() registerDefaults:defaults];
			_defaultKeysAndValues = defaults;
		}
		_changedKeys = [NSMutableSet new];
		_typesForKeys = [NSMutableDictionary new];
    }
    return self;
}


// ========================================================================== //

#pragma mark - Public



- (void) resetDefaults {
	//TODO: resetDefaults
}

- (BOOL) valueWasSetForKey:(NSString *)key {
	return [_changedKeys containsObject:key];
}

- (id) valueForKey:(NSString *)defaultsKey defaultValue:(id)defaultValue wasChanged:(BOOL *)wasChanged {
	return nil; //TODO: wasChanged:
}



// ========================================================================== //

#pragma mark - Key Accessors


#if TARGET_OS_IPHONE
- (UIColor *) colorForKey:(NSString *)key {
	UIColor *color = nil;
	NSData *colorData = [self valueForKeySynchronized:key];
	if (colorData) {
		color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
	}
	return color;
}

- (void) setColor:(UIColor *)color forKey:(NSString *)key {
	[self setValueSynchronized:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:key];
}
#else
- (NSColor *) colorForKey:(NSString *)key {
	return nil;
}

- (void) setColor:(NSColor *)color forKey:(NSString *)key {
	
}
#endif

#if TARGET_OS_IPHONE
/** @todo - implement color <-> hex string conversions. */
- (UIColor *) colorFromHexStringForKey:(NSString *)key {
	return nil;
}

/** @todo - implement color <-> hex string conversions. */
- (void) setHexStringForColor:(UIColor *)color forKey:(NSString *)key {
	
}
#else
/** @todo - implement color <-> hex string conversions. */
- (NSColor *) colorFromHexStringForKey:(NSString *)key {
	return nil;
}

/** @todo - implement color <-> hex string conversions. */
- (void) setHexStringForColor:(NSColor *)color forKey:(NSString *)key {
	
}
#endif

#if TARGET_OS_IPHONE
- (CGPoint) pointForKey:(NSString *)key {
	return CGPointFromString([self valueForKeySynchronized:key]);
}

- (void) setPoint:(CGPoint)point forKey:(NSString *)key {
	[self setValueSynchronized:NSStringFromCGPoint(point) forKey:key];
}
#else
- (NSPoint) pointForKey:(NSString *)key {
	return NSPointFromString([self valueForKeySynchronized:key]);
}
- (void) setPoint:(NSPoint)point forKey:(NSString *)key {
	[self setValueSynchronized:NSStringFromPoint(point) forKey:key];
}
#endif



// ========================================================================== //

#pragma mark - Compatibility


- (id)objectForKey:(NSString *)defaultName {
	return [self valueForKeySynchronized:defaultName];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
	[self setValueSynchronized:value forKey:defaultName];
}

- (void)removeObjectForKey:(NSString *)defaultName {
	/// ?
}

- (NSString *)stringForKey:(NSString *)defaultName {
	return [self valueForKeySynchronized:defaultName];
}

- (NSArray *)arrayForKey:(NSString *)defaultName {
	return [self valueForKeySynchronized:defaultName];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName {
	return [self valueForKeySynchronized:defaultName];
}

- (NSData *)dataForKey:(NSString *)defaultName {
	return [self valueForKeySynchronized:defaultName];
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName {
	return [self valueForKeySynchronized:defaultName];
}

- (NSInteger)integerForKey:(NSString *)defaultName {
	return [[self valueForKeySynchronized:defaultName] integerValue];
}

- (float)floatForKey:(NSString *)defaultName {
	return [[self valueForKeySynchronized:defaultName] floatValue];
}

- (double)doubleForKey:(NSString *)defaultName {
	return [[self valueForKeySynchronized:defaultName] doubleValue];
}

- (BOOL)boolForKey:(NSString *)defaultName {
	return [[self valueForKeySynchronized:defaultName] boolValue];
}

- (NSURL *)URLForKey:(NSString *)defaultName {
	return [self valueForKeySynchronized:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
	[self setValueSynchronized:[NSNumber numberWithInteger:value] forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName {
	[self setValueSynchronized:[NSNumber numberWithFloat:value] forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName {
	[self setValueSynchronized:[NSNumber numberWithDouble:value] forKey:defaultName];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
	[self setValueSynchronized:[NSNumber numberWithBool:value] forKey:defaultName];
}

- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName {
	[self setValueSynchronized:url forKey:defaultName];
}




// ========================================================================== //

#pragma mark - KVO


// Extensions that synchronize the defaults


- (id) valueForKeySynchronized:(NSString *)key {
	[StandardDefaults() synchronize];
	return [StandardDefaults() valueForKey:key];
}

- (void) setValueSynchronized:(id)value forKey:(NSString *)key {
	[self willChangeValueForKey:key];
	[_changedKeys addObject:key];
	[StandardDefaults() setValue:value forKey:key];
	[StandardDefaults() synchronize];
	[self didChangeValueForKey:key];
}

// Overrides the read/write to defaults

- (id)valueForKey:(NSString *)key {
	return [self valueForKeySynchronized:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
	[self setValueSynchronized:value forKey:key];
}

- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys {
	return [[StandardDefaults() dictionaryRepresentation] dictionaryWithValuesForKeys:keys];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
	for (NSString *key in keyedValues) {
		[self willChangeValueForKey:key];
	}
	[StandardDefaults() setValuesForKeysWithDictionary:keyedValues];
	[StandardDefaults() synchronize];
	for (NSString *key in keyedValues) {
		[self didChangeValueForKey:key];
	}
}



@end
