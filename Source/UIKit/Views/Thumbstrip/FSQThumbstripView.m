//
//  FSQThumbstripView.m
//  FivesquareKit
//
//  Created by John Clayton on 4/19/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQThumbstripView.h"

@interface FSQThumbstripView ()
- (void) initialize;
@end

@implementation FSQThumbstripView

// ========================================================================== //

#pragma mark - Properties

@synthesize dataSource=dataSource_;
@synthesize delegate=delegate_;
@synthesize cellWidth=cellWidth_;
@synthesize backgroundView=backgroundView_;

@dynamic visibleCells;
- (NSArray *) visibleCells {
	return nil;
}

@dynamic visibleRange;
- (NSRange) visibleRange {
	return NSMakeRange(NSNotFound, 0);
}


// ========================================================================== //

#pragma mark - Object



- (void) initialize {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

// ========================================================================== //

#pragma mark - Public interface

- (void) selectCellAtIndex:(NSInteger)index animated:(BOOL)animated {
	
}

- (void) deselectCellAtIndex:(NSInteger)index animated:(BOOL)animated {
	
}


- (void) reloadData {
	
}





@end
