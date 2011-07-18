//
//  NSFileManager+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 8/9/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (FSQFoundation)

- (BOOL)sizeEqualAtPath:(NSString *)path1 andPath:(NSString *)path2;

@end
