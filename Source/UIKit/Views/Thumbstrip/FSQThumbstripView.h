//
//  FSQThumbstripView.h
//  FivesquareKit
//
//  Created by John Clayton on 4/19/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSQThumbstripView;
@class FSQThumbstripCell;
@protocol FSQThumbstripDataSource;

@protocol FSQThumbstripDelegate <NSObject, UIScrollViewDelegate>

@optional

// Display customization

- (void) thumbstripView:(FSQThumbstripView *)thumbstripView willDisplayCell:(FSQThumbstripCell *)cell forItemAtIndex:(NSInteger)index;
- (CGSize) thumbstripView:(FSQThumbstripView *)thumbstripView sizeForCellAtIndex:(NSInteger)index;

// Selection

- (void)thumbstripView:(FSQThumbstripView *)thumbstripView didSelectViewAtIndex:(NSInteger)index;
- (void)thumbstripView:(FSQThumbstripView *)thumbstripView didDeselectRowAtIndex:(NSInteger)index;


@end

@interface FSQThumbstripView : UIScrollView <UIAppearanceContainer>

@property (nonatomic, weak) id<FSQThumbstripDataSource> dataSource; 
@property (nonatomic, weak) id<FSQThumbstripDelegate> delegate; 

@property (nonatomic, strong) Class cellClass;

// Appearance

@property (nonatomic) CGSize cellSize; ///< Default is 200x200
@property (nonatomic, weak) UIView *backgroundView UI_APPEARANCE_SELECTOR;


// Info

- (FSQThumbstripCell *) cellAtIndex:(NSInteger)index;
- (NSInteger) indexForCellAtPoint:(CGPoint)point;
- (NSIndexSet *) indexesForCellsInRect:(CGRect)rect;

// selection

@property (nonatomic, strong, readonly) NSSet *visibleCells;
@property (nonatomic, readonly) NSRange visibleRange; ///< Returns the range of indices that are visible, with the location being the index of the first visible cell, and the length being the number of cells that are visible.

- (void) selectCellAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void) deselectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

// Data

- (void) reloadData;
- (id) dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end


@protocol FSQThumbstripDataSource <NSObject>

@required

- (NSInteger) numberOfItemsInthumbstripView:(FSQThumbstripView *)thumbstripView;
- (NSArray *) thumbstripView:(FSQThumbstripView *)thumbstripView cellsForRange:(NSRange)range;
- (FSQThumbstripCell *) thumbstripView:(FSQThumbstripView *)thumbstripView cellForIndex:(NSInteger)index;


@end

