//
//  FSQMenuControl+Protected.h
//  FivesquareKit
//
//  Created by John Clayton on 4/10/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQMenuControl.h"

@interface FSQMenuControl ()
@property (nonatomic, strong) NSMutableArray *itemsInternal;
@property (nonatomic, weak) UIImageView *backgroundImageView;
@property (nonatomic, weak) UIScrollView *contentView;
@property (nonatomic, readonly) NSArray *itemViews;
- (void) setItemsSelectionStyle:(FSQMenuSelectionStyle)selectionStyle;
@end
