//
//  NSValue+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 9/20/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (FSQFoundation)


#if TARGET_OS_IPHONE == 0
+ (id) valueWithCGRect:(CGRect)rect;
- (CGRect) CGRectValue;
#endif


@end
