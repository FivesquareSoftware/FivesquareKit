//
//  FSQTextViewCell.h
//  Fivesquare Kit
//
//  Created by John Clayton on 12/6/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FSQTextViewCell : UITableViewCell {
	UITextView *__unsafe_unretained textView;
}

@property (nonatomic, assign) IBOutlet UITextView *textView;

@end
