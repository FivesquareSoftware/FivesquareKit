//
//  FSQThumbstripCell.h
//  FivesquareKit
//
//  Created by John Clayton on 4/19/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQThumbstripCell : UIControl
@property (nonatomic, strong, readonly) NSString *reuseIdentifier;
@property (nonatomic, weak, readonly) UIView *contentView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void) prepareForReuse; ///< Subclasses can override to reset default state 

@end
