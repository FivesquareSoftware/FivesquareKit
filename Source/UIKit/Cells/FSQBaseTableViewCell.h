//
//  FSQBaseTableViewCell.h
//  FivesquareKit
//
//  Created by John Clayton on 8/2/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSQBaseTableViewCell : UITableViewCell

- (void) initialize; // Called when created via init or initWithCoder
- (void) ready; // Called when all views are loaded (i.e. awakeFromNib)

@end
