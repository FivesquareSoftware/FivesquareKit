//
//  FSQMenuItem.h
//  FivesquareKit
//
//  Created by John Clayton on 4/9/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface FSQMenuItem : NSObject

@property (nonatomic, strong) id representedObject;
@property (nonatomic, strong) NSString *displayNameKeyPath;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, weak) id menu;

+ (id) withRepresentedObject:(id)representedObject;
+ (id) withRepresentedObject:(id)representedObject displayName:(NSString *)displayName;

- (id) initWithRepresentedObject:(id)representedObject;

@end
