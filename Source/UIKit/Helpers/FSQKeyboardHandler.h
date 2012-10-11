//
//  FSQKeyboardHandler.h
//  FivesquareKit
//
//  Created by John Clayton on 5/30/2010.
//  Copyright 2010 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Implements simple keyboard management, resizing the associated view controller's
 *  view by the amount the keyboard intrudes into it's bounds. Probably good for 
 *  80% of the cases you'll encounter. You could subclass it if you wanted to get
 *  some fancier behavior.
 */
@interface FSQKeyboardHandler : NSObject {
}

/** Whether the keyboard should stay up and not animate subsequent will hide 
 *  notifications. Useful for forms when you want to keep the keyboard up as
 *  the user tabs (heh) between fields. When you want the keyboard to resign,
 *  you need to set this to NO.
 */
@property (nonatomic,assign) BOOL keepKeyboardUp;

/** The view controller to manage the keyboard for. */
@property (nonatomic, weak) IBOutlet UIViewController *viewController;

- (id) initWithViewController:(UIViewController *)aViewController;

@end
