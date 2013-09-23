//
//  NSError+FSQFoundation.h
//  FivesquareKit
//
//  Created by John Clayton on 7/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (FSQFoundation)

+ (id) errorWithException:(NSException *)exception;
+ (id) errorWithError:(NSError *)underlyingError localizedDescription:(NSString *)localizedDescription;
+ (id) errorWithError:(NSError *)underlyingError domain:(NSString *)errorDomain code:(NSInteger)errorCode localizedDescription:(NSString *)localizedDescription;
+ (NSString *) bestErrorMessageForError:(NSError *)error;
+ (NSString *) bestErrorMessageForError:(NSError *)error defaultMessage:(NSString *)defaultMessage;

@end
