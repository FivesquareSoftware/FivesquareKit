//
//  FSQAppBooter.h
//  FivesquareKit
//
//  Created by John Clayton on 1/30/2011.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSQAppBooterDelegate;

@interface FSQAppBooter : NSObject {

}

@property (nonatomic, weak) id<FSQAppBooterDelegate> delegate;


- (void) addOperation:(NSOperation *)operation;
- (void) addBootOperations:(NSArray *)operations;
- (void) boot;

@end


@protocol FSQAppBooterDelegate <NSObject>
- (void) booterFinishedBooting:(FSQAppBooter *)booter;
@end
