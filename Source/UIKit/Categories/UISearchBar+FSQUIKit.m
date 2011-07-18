//
//  UISearchBar+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 8/18/2009.
//  Copyright 2009 Fivesquare Software, LLC. All rights reserved.
//

#import "UISearchBar+FSQUIKit.h"


@implementation UISearchBar (FSQUIKit)

@dynamic returnKeyType;
@dynamic textField;

- (void)setReturnKeyType:(UIReturnKeyType)type {
	self.textField.returnKeyType = type;
}

- (UIReturnKeyType)returnKeyType {
	return self.textField.returnKeyType;
}

- (UITextField *) textField {
	UITextField *textField = nil;
	for (id subview in [self subviews]) {
		if ([subview isKindOfClass:[UITextField class]]) {
			textField = (UITextField *)subview;
			break;
		}
	}
	return textField;
}

- (UIView *) backgroundView {
	UIView *backgroundView = nil;
	for (id subview in [self subviews]) {
		NSString *subviewClassName = NSStringFromClass([subview class]);
		if ([subviewClassName isEqualToString:@"UISearchBarBackground"]) {
			backgroundView = (UIView *)subview;
			break;
		}
	}
	return backgroundView;
}

- (UIButton *) cancelButton {
	UIButton *cancelButton = nil;
	for (id subview in [self subviews]) {
		NSString *subviewClassName = NSStringFromClass([subview class]);
		if ([subviewClassName isEqualToString:@"UINavigationButton"]) {
			if([[(NSObject *)subview performSelector:@selector(title)] isEqualToString:@"Cancel"]) {
				cancelButton = (UIButton *)subview;
				break;
			}
		}
	}
	return cancelButton;
}


@end
