//
//  NSObject+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 11/16/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSObject (FSQUIKit)

@property (nonatomic, readonly) id appDelegate;

+ (NSString *)nibName;
+ (id) loadFromNib;
+ (id) loadFromNibWithOwner:(id)owner;

@end