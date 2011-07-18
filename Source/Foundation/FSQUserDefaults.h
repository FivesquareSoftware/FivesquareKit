//
//  FSQUserDefaults.h
//  FivesquareKit
//
//  Created by John Clayton on 1/30/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSQUserDefaults : NSObject {

}

+ (id) sharedDefaults;

+ (void) registerDefaults:(NSString *)fileName;
+ (void) resetDefaults;

- (id) valueForKey:(NSString *)defaultsKey defaultValue:(id)defaultValue wasLoaded:(BOOL *)wasLoaded;
- (BOOL) keyWasLoaded:(NSString *)defaultsKey;


@end
