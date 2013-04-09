//
//  FSQObjectButton.h
//  FivesquareKit
//
//  Created by John Clayton on 4/8/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSQButtonObject <NSObject>
@optional
- (UIImage *) image;
- (NSString *) title;
@end

@interface FSQObjectButton : UIButton
@property (nonatomic, strong) id placeholderObject;
@property (nonatomic, strong) id representedObject;
@end
