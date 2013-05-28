//
//  FSQCoreAnimationUtils.m
//  FivesquareKit
//
//  Created by John Clayton on 5/13/13.
//  Copyright (c) 2013 Fivesquare Software, LLC. All rights reserved.
//

#import "FSQCoreAnimationUtils.h"



NSTimeInterval CATransactionCurrentAnimationDuration() {
	return (NSTimeInterval)[CATransaction animationDuration];
}