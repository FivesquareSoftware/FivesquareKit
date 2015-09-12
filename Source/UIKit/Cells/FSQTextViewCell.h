//
//  FSQTextViewCell.h
//  Fivesquare Kit
//
//  Created by John Clayton on 12/6/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSQBaseTableViewCell.h"


@interface FSQTextViewCell : FSQBaseTableViewCell <UITextViewDelegate>

@property (nonatomic, assign) IBOutlet UITextView *textView;

	@property (nonatomic, copy) void(^onEditingBegan)(NSString *text);
	@property (nonatomic, copy) BOOL(^shouldChangeCharactersInRange)(NSRange range, NSString *replacementString);
	@property (nonatomic, copy) void(^onChange)(NSString *text);
	@property (nonatomic, copy) BOOL(^shouldEnd)(NSString *text);
	@property (nonatomic, copy) void(^onEditingEnded)(NSString *text);

@end
