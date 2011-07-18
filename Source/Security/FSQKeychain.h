//
//  FSQKeychain.h
//  FivesquareKit
//
//  Created by John Clayton on 4/26/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Security/Security.h>

@interface FSQKeychain : NSObject {

}

#if TARGET_OS_IPHONE
+ (NSString *) passwordForIdentifier:(NSString *)identifier;
+ (void) savePassword:(NSString *)password forIdentifier:(NSString *)identifier;
#endif

@end
