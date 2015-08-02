//
//  UIDevice+FSQUIKit.h
//  FivesquareKit
//
//  Created by John Clayton on 5/10/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (FSQUIKit)

@property (nonatomic, readonly) BOOL iPhone;
@property (nonatomic, readonly) BOOL iPad;

@property (nonatomic, readonly) BOOL iPhone4;
@property (nonatomic, readonly) BOOL iPhone5;
@property (nonatomic, readonly) BOOL iPhone6;
@property (nonatomic, readonly) BOOL iPhone6Simulator;
@property (nonatomic, readonly) BOOL iPhone6Plus;
@property (nonatomic, readonly) BOOL iPhone6PlusSimulator;

@property (nonatomic, readonly) BOOL isBigPhone;
@property (nonatomic, readonly) BOOL isSmallPhone;


- (NSString *) newPersistentIdentifier;

@end
