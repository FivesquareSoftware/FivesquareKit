//
//  NSURL+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 5/17/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (FSQFoundation)

- (NSString *) scaleModifier;
- (float) scale;

- (NSURL *) URLBySettingScale:(float)scale;
- (NSURL *) URLByDeletingScale;


@end
