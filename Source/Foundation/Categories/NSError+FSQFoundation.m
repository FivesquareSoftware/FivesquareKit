//
//  NSError+FSQFoundation.m
//  FivesquareKit
//
//  Created by John Clayton on 7/29/12.
//  Copyright (c) 2012 Fivesquare Software, LLC. All rights reserved.
//

#import "NSError+FSQFoundation.h"

#import "NSString+FSQFoundation.h"
#import "NSDictionary+FSQFoundation.h"


@implementation NSError (FSQFoundation)

+ (id) errorWithException:(NSException *)exception {
	if (nil == exception) {
		return nil;
	}
	NSMutableDictionary *info = [NSMutableDictionary new];
	info[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"An exception occurred: %@",[exception name]];
	[info setObjectIfNotNil:exception forKey:@"exception"];
	[info setObjectIfNotNil:[exception reason] forKey:@"reason"];
	[info setObjectIfNotNil:[exception callStackSymbols] forKey:@"callStackSymbols"];
	[info setObjectIfNotNil:[exception userInfo] forKey:@"userInfo"];
	
	NSError *error = [NSError errorWithDomain:@"Exception Error Domain" code:-999 userInfo:info];
	return error;
}

+ (id) errorWithError:(NSError *)underlyingError localizedDescription:(NSString *)localizedDescription {
	return [self errorWithError:underlyingError domain:underlyingError.domain code:underlyingError.code localizedDescription:localizedDescription];
}

+ (id) errorWithError:(NSError *)underlyingError domain:(NSString *)errorDomain code:(NSInteger)errorCode localizedDescription:(NSString *)localizedDescription {
	NSMutableDictionary *info = [NSMutableDictionary new];
	if (underlyingError) {
		[info addEntriesFromDictionary:underlyingError.userInfo];
		info[NSUnderlyingErrorKey] = underlyingError;
	}
	info[NSLocalizedDescriptionKey] = localizedDescription;
	NSError *error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:info];
	return error;
}

+ (NSString *) bestErrorMessageForError:(NSError *)error {
	return [self bestErrorMessageForError:error defaultMessage:i18n(@"Unknown Error",@"Unknown Error Message")];
}

+ (NSString *) bestErrorMessageForError:(NSError *)error defaultMessage:(NSString *)defaultMessage {
	NSString *message;
	if (error) {
		message = [error localizedFailureReason];
		if ([NSString isEmpty:message]) {
			message = [error localizedDescription];
		}
	}
	if ([NSString isEmpty:message]) {
		message = defaultMessage;
	}
	return message;
}


@end
