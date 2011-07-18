//
//  FSQLabledSwitchCell.h
//  FivesquareKit
//
//  Created by John Clayton on 12/9/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSQLabeledControlCell : UITableViewCell {
}

@property (nonatomic, weak) IBOutlet UIControl *control;
@property (nonatomic, weak) IBOutlet UILabel *controlLabel;

@end
