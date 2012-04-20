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
- (CGFloat) thumbstripView:(FSQThumbstripView *)thumbstripView widthForCellAtIndex:(NSInteger)index;
- (NSString *) captionForthumbstripView:(FSQThumbstripView *)thumbstripView;

// Selection

- (void)thumbstripView:(FSQThumbstripView *)thumbstripView didSelectViewAtIndex:(NSInteger)index;
- (void)thumbstripView:(FSQThumbstripView *)thumbstripView didDeselectRowAtIndex:(NSInteger)index;


@end

@interface FSQThumbstripView : UIScrollView <UIAppearanceContainer>

@property (nonatomic, weak) id<FSQThumbstripDataSource> dataSource; 
@property (nonatomic, weak) id<FSQThumbstripDelegate> delegate; 

// Appearance

@property (nonatomic) CGFloat cellWidth; ///< Default is 170
@property (nonatomic, weak) UIView *backgroundView UI_APPEARANCE_SELECTOR;


// selection

@property (nonatomic, readonly) NSArray *visibleCells;
@property (nonatomic, readonly) NSRange visibleRange;

- (void) selectCellAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void) deselectCellAtIndex:(NSInteger)index animated:(BOOL)animated;

// Data

- (void) reloadData;

@end


@protocol FSQThumbstripDataSource <NSObject>

@required

- (NSInteger) numberOfItemsInthumbstripView:(FSQThumbstripView *)thumbstripView;
- (NSArray *) thumbstripView:(FSQThumbstripView *)thumbstripView cellsForRange:(NSRange)range;
- (FSQThumbstripCell *) thumbstripView:(FSQThumbstripView *)thumbstripView cellForIndex:(NSInteger)index;


@end

