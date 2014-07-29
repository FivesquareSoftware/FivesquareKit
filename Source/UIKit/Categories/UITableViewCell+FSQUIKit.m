//
//  UITableViewCell+UITableViewCell_FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 7/28/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "UITableViewCell+FSQUIKit.h"

@implementation UITableViewCell (FSQUIKit)

@dynamic tableView;
- (UITableView *) tableView {
	UITableView *tableView = nil;
	UIResponder *responder = [self nextResponder];
	while (responder) {
		if ([responder isKindOfClass:[UITableView class]]) {
			tableView = (UITableView *)responder;
			break;
		}
		responder = [responder nextResponder];
	}
	return tableView;
}

@end
