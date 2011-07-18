//
//  FSQSandbox.h
//  FivesquareKit
//
//  Created by John Clayton on 1/29/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSQSandbox : NSObject {

}

+ (NSString *) documentsDirectory;
+ (NSString *) applicationSupportDirectory;
+ (NSString *) cachesDirectory;

+ (NSString *) documentsDirectory:(BOOL)shouldCreate;
+ (NSString *) applicationSupportDirectory:(BOOL)shouldCreate;
+ (NSString *) cachesDirectory:(BOOL)shouldCreate;

@end
