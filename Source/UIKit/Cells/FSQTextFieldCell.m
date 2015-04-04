//
//  FSQTextFieldCell.m
//  Fivesquare Kit
//
//  Created by John Clayton on 10/29/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQTextFieldCell.h"


@interface FSQTextFieldCell ()
@property (nonatomic, strong) id textChangeObserver;

@end

@implementation FSQTextFieldCell

+ (BOOL) requiresConstraintBasedLayout {
	return YES;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self.textChangeObserver];
}

- (void) initialize {
	[super initialize];
}

- (void) ready {
	[super ready];
	[self.textField setDelegate:self];
	[self.textField setReturnKeyType:UIReturnKeyDefault];

	FSQWeakSelf(self_);
	self.textChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:_textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		if (self_.onChange) {
			self_.onChange([self_.textField text]);
		}
	}];

}
- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self initialize];
		[self ready];
	}
	return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self ready];
}

- (void) prepareForReuse {
	[super prepareForReuse];
}

- (BOOL) becomeFirstResponder {
	return [self.textField becomeFirstResponder];
}

- (BOOL) resignFirstResponder {
	[super resignFirstResponder]; // stfu analyzer
	return [self.textField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	if (_onReturn) {
		_onReturn(textField.text);
	}
	[self resignFirstResponder];
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
	if (_onEditingEnded) {
		_onEditingEnded(textField.text);
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (_shouldChangeCharactersInRange) {
		return _shouldChangeCharactersInRange(range,string);
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	if (_onClear) {
		return _onClear();
	}
	return YES;
}

@end
