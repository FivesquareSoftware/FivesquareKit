//
//  FSQTextFieldCell.m
//  Fivesquare Kit
//
//  Created by John Clayton on 10/29/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTextFieldCell.h"


@implementation FSQTextFieldCell

- (BOOL) becomeFirstResponder {
	return [self.textField becomeFirstResponder];
}

@end
