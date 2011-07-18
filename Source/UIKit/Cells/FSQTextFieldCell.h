//
//  FSQTextFieldCell.h
//  Fivesquare Kit
//
//  Created by John Clayton on 10/29/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSQTextFieldCell : UITableViewCell {
	UITextField *__unsafe_unretained textField;
}

@property (nonatomic, assign) IBOutlet UITextField *textField;

@end
