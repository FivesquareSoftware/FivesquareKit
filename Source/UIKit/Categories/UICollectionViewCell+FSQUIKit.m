//
//  UICollectionViewCell+FSQUIKit.m
//  FivesquareKit
//
//  Created by John Clayton on 7/28/14.
//  Copyright (c) 2014 Fivesquare Software, LLC. All rights reserved.
//

#import "UICollectionViewCell+FSQUIKit.h"

@implementation UICollectionViewCell (FSQUIKit)

@dynamic collectionView;
- (UICollectionView *) collectionView {
	UICollectionView *collectionView = nil;
	UIResponder *responder = [self nextResponder];
	while (responder) {
		if ([responder isKindOfClass:[UICollectionView class]]) {
			collectionView = (UICollectionView *)responder;
			break;
		}
		responder = [responder nextResponder];
	}
	return collectionView;
}

@end
