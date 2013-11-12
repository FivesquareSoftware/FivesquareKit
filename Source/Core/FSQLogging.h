//
//  FSQLogging.h
//  FivesquareKit
//
//  Created by John Clayton on 7/17/11.
//  Copyright 2011 Fivesquare Software, LLC. All rights reserved.
//


#define FSQ_FILE(file) [[NSString stringWithUTF8String:file] lastPathComponent]

#ifndef NS_BLOCK_ASSERTIONS
	#define FLog(frmt, ...) NSLog(@" - %@:%d %s - %@", FSQ_FILE(__FILE__), __LINE__,  __PRETTY_FUNCTION__, [NSString stringWithFormat:frmt, ##__VA_ARGS__])
    #define FLogMark(name,frmt, ...) NSLog(@" - [%@] - %@", name, [NSString stringWithFormat:frmt, ##__VA_ARGS__])
	#define FLogMarkIf(condition,name,frmt,...) if(condition) FLogMark(name,frmt, ##__VA_ARGS__)
	#define FLogError(error, frmt, ...) FLogMark(@"ERROR",@"%@:%d %s - %@ %@ (%@)", FSQ_FILE(__FILE__), __LINE__,  __PRETTY_FUNCTION__, [NSString stringWithFormat:frmt, ##__VA_ARGS__], [(NSError *)error localizedDescription], [(NSError *)error userInfo])
	#define FLogMethod() FLog(@"-->")
	#define FLogSimple(frmt, ...) NSLog(frmt, ##__VA_ARGS__)
	#define FLogDebug(frmt, ...) FLogMark(@"DEBUG",frmt, ##__VA_ARGS__)
	#define FLogDebugIf(condition, frmt, ...) if(condition) FLogDebug(frmt, ##__VA_ARGS__)
    #define FLogWarn(frmt, ...) FLogMark(@"WARN",frmt, ##__VA_ARGS__)
	#define FLogTime(start,frmt, ...) NSLog(@" - [TIMED] - %@s - %@", @(-[start timeIntervalSinceNow]), [NSString stringWithFormat:frmt, ##__VA_ARGS__])
#else
	#define FLog(frmt, ...)
	#define FLogError(error, frmt, ...)
	#define FLogMethod()
	#define FLogSimple(frmt, ...)
	#define FLogMark(name,frmt, ...)
	#define FLogMarkIf(condition,name,frmt,...)
	#define FLogDebug(frmt, ...)
    #define FLogDebugIf(condition,frmt,...)
	#define FLogWarn(frmt, ...)
    #define FLogTime(start,frmt, ...)
#endif
