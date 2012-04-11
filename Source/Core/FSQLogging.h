//
//  FSQLogging.h
//  FivesquareKit
//
//  Created by John Clayton on 7/17/11.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//


#define FSQ_FILE(file) [[NSString stringWithUTF8String:file] lastPathComponent]

#ifndef NS_BLOCK_ASSERTIONS
	#define FLog(frmt, ...) NSLog(@" - %@:%d %s - %@", FSQ_FILE(__FILE__), __LINE__,  __PRETTY_FUNCTION__, [NSString stringWithFormat:frmt, ##__VA_ARGS__]);
	#define FLogError(error, frmt, ...) NSLog(@" - %@:%d %s - %@ %@ (%@)", FSQ_FILE(__FILE__), __LINE__,  __PRETTY_FUNCTION__, [NSString stringWithFormat:frmt, ##__VA_ARGS__], [error localizedDescription], [error userInfo]);
#else
	#define FLog(frmt, ...)
	#define FLogError(error, frmt, ...)
#endif
