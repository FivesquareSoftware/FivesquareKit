//
//  FSQDetailImageView.h
//  FivesquareKit
//
//  Created by John Clayton on 8/2/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FSQImagePicker <NSObject>
- (void) beginImagePicking:(id)sender;
@end


@interface FSQDetailImageView : UIView {
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *renderedImage;
@property (nonatomic, assign) CGFloat borderRadius;

@property (nonatomic, assign) BOOL zoomsImage;
@property (nonatomic, assign) BOOL editing;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@end
