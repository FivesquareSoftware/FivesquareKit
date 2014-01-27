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

/* @deprecated */
+ (id) loadFromNib;
/* @deprecated */
+ (id) loadFromNibWithOwner:(id)owner;


+ (id) withNibOwner:(id)owner;
+ (id) withNib:(UINib *)nib owner:(id)owner;


@end