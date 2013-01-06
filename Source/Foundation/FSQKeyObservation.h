//
//  FSQKeyObservation.h
//  FivesquareKit
//
//  Created by John Clayton on 12/31/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQKeyObservation : NSObject
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, copy) void(^block)(id value);

@property (nonatomic, readonly) NSString *key;

@end
