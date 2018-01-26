//
//  FSQTextViewCell.m
//  Fivesquare Kit
//
//  Created by John Clayton on 12/6/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTextViewCell.h"


@interface FSQTextViewCell () 


@end

@implementation FSQTextViewCell 

- (void) ready {
	[super ready];
	[self.textView setDelegate:self];
}

- (BOOL) becomeFirstResponder {
	return [self.textView becomeFirstResponder];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	if (_automaticallyEnabledTextViewForEditing) {
		self.textView.editable = editing;
	}
}

- (void) setAutomaticallyEnabledTextFieldForEditing:(BOOL)automaticallyEnabledTextViewForEditing {
	if (_automaticallyEnabledTextViewForEditing != automaticallyEnabledTextViewForEditing) {
		_automaticallyEnabledTextViewForEditing = automaticallyEnabledTextViewForEditing;
		self.textView.editable = self.editing;
	}
}


// ========================================================================== //

#pragma mark - UITextViewDelegate



- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	BOOL shouldEnd = YES;
	if (_shouldEnd) {
		 shouldEnd = _shouldEnd(textView.text);
	}
	if (shouldEnd) {
		[self resignFirstResponder];
	}
	return shouldEnd;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if (_onEditingBegan) {
		_onEditingBegan(textView.text);
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if (_onEditingEnded) {
		_onEditingEnded(textView.text);
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if (_shouldChangeCharactersInRange) {
		return _shouldChangeCharactersInRange(range,text);
	}
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
	if (_onChange) {
		_onChange([textView text]);
	}
}




@end
