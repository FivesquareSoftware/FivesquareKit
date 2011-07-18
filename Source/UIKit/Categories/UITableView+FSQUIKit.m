//
//  UITableView+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 8/25/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import "UITableView+FSQUIKit.h"


@implementation UITableView (FSQUIKit)


- (void) clearSelectionAnimated:(BOOL)animated {
    NSIndexPath *selectedIndex = [self indexPathForSelectedRow];
    if(selectedIndex != nil) {
        [self deselectRowAtIndexPath:selectedIndex animated:animated];
    }
}


- (void) scrollToTopAnimated:(BOOL)animated {
    [self setContentOffset:CGPointZero animated:NO];
}

@end
