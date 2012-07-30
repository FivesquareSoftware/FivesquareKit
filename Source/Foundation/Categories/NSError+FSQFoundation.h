//
//  NSError+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 7/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (FSQFoundation)

+ (id) withException:(NSException *)exception;

@end
