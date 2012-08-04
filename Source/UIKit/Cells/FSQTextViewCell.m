//
//  FSQTextViewCell.m
//  Fivesquare Kit
//
//  Created by John Clayton on 12/6/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTextViewCell.h"


@implementation FSQTextViewCell

- (BOOL) becomeFirstResponder {
	return [self.textView becomeFirstResponder];
}

@end
