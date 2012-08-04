//
//  FSQLeftDetailCell.h
//  FivesquareKit
//
//  Created by John Clayton on 8/1/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQBaseTableViewCell.h"

@interface FSQLeftDetailCell : FSQBaseTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *annotationLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
