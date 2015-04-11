//
//  FSQTextFieldCell.h
//  Fivesquare Kit
//
//  Created by John Clayton on 10/29/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQBaseTableViewCell.h"


@interface FSQTextFieldCell : FSQBaseTableViewCell <UITextFieldDelegate> {
@protected
	__weak UITextField *_textField;
}

@property (nonatomic,weak) IBOutlet UITextField *textField;


@property (nonatomic, copy) void(^onEditingBegan)(NSString *text);
@property (nonatomic, copy) BOOL(^shouldChangeCharactersInRange)(NSRange range, NSString *replacementString);
@property (nonatomic, copy) void(^onChange)(NSString *text);
@property (nonatomic, copy) BOOL(^onClear)();
@property (nonatomic, copy) void(^onReturn)(NSString *text);
@property (nonatomic, copy) void(^onEditingEnded)(NSString *text);


@end
