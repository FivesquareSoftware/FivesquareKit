//
//  FSQActionSheet.h
//  FivesquareKit
//
//  Created by John Clayton on 1/14/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQActionSheet : UIActionSheet

- (void) showInView:(UIView *)view withDismissHandler:(void(^)(UIActionSheet *actionSheet, NSInteger buttonIndex))dismissHandler;
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
