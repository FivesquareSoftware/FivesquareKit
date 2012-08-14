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

- (NSString *) newPersistentIdentifier;

@end
