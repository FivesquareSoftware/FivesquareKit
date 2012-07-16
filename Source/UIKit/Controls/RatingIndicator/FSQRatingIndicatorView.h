//
//  GARatingIndicator.h
//  FivesquareKit
//
//  Created by John Clayton on 11/6/2008.
//  Copyright 2008 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSQRatingIndicatorView;

@protocol FSQRatingIndicatorDelegate
- (void) ratingIndicatorValueChanged:(FSQRatingIndicatorView *)aRatingIndicator;
@end


@interface FSQRatingIndicatorView : UIView {
}

@property (nonatomic, weak) IBOutlet id<FSQRatingIndicatorDelegate> delegate;

@property (nonatomic, strong) UIImage *offImage;
@property (nonatomic, strong) UIImage *onImage;
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSUInteger segments;

@end
