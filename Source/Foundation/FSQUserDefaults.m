//
//  FSQUserDefaults.m
//  FivesquareKit
//
//  Created by John Clayton on 1/30/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQUserDefaults.h"


@interface FSQUserDefaults()

@end


@implementation FSQUserDefaults

+ (id) sharedDefaults {
	static FSQUserDefaults *sharedDefaults = nil;
	@synchronized(self) {
		if (sharedDefaults == nil) {
			sharedDefaults = [[self alloc] init];
		}
	}
	return sharedDefaults;
}

+ (void) resetDefaults {
	//TODO: resetDefaults
}

+ (void) registerDefaults:(NSString *)fileName {
	NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
	if(defaults) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	}
}

- (id) valueForKey:(NSString *)defaultsKey defaultValue:(id)defaultValue wasLoaded:(BOOL *)wasLoaded {
	return nil; //TODO: valueForKey:defaultValue:wasLoaded:
}

- (BOOL) keyWasLoaded:(NSString *)defaultsKey {
	return NO; //TODO: keyWasLoaded:
}


@end
