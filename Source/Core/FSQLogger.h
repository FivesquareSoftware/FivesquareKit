//
//  FSQLogger.h
//  FivesquareKit
//
//  Created by John Clayton on 9/29/04.
//  Copyright 2004 Fivesquare Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOG_OFF  99
#define LOG_FATAL  50
#define LOG_ERROR  40
#define LOG_WARN  30
#define LOG_INFO  20
#define LOG_DEBUG  10
#define LOG_TRACE  0

#ifndef LOG_LEVEL
#define LOG_LEVEL LOG_FATAL
#endif

#define FSQ_LOCATION lineNumber: __LINE__ fileName: __FILE__ methodName: __PRETTY_FUNCTION__
#define NO_LINE_NUMBER -1


#if(LOG_TRACE >= LOG_LEVEL)
#define logTrace(format, args...) [FSQLogger trace:format FSQ_LOCATION , ## args]
#else
#define logTrace(format, args...)
#endif

#if(LOG_DEBUG >= LOG_LEVEL)
#define logDebug(format, args...) [FSQLogger debug:format FSQ_LOCATION , ## args]
#else
#define logDebug(format, args...)
#endif

#if(LOG_INFO >= LOG_LEVEL)
#define logInfo(format, args...) [FSQLogger info:format FSQ_LOCATION , ## args]
#else
#define logInfo(format, args...)
#endif

#if(LOG_WARN >= LOG_LEVEL)
#define logWarn(format, args...) [FSQLogger warn:format FSQ_LOCATION , ## args]
#else
#define logWarn(format, args...)
#endif

#if(LOG_ERROR >= LOG_LEVEL)
#define logError(format, args...) [FSQLogger error:format FSQ_LOCATION , ## args]
#else
#define logError(format, args...)
#endif

#if(LOG_FATAL >= LOG_LEVEL)
#define logFatal(format, args...) [FSQLogger fatal:format FSQ_LOCATION , ## args] 
#else
#define logFatal(format, args...)
#endif





@interface FSQLogger : NSObject {
}


+ (void) trace:(NSString *)aFormat,...;
+ (void) debug:(NSString *)aFormat,...;
+ (void) info:(NSString *)aFormat,...;
+ (void) warn:(NSString *)aFormat,...;
+ (void) error:(NSString *)aFormat,...;
+ (void) fatal:(NSString *)aFormat,...;

+ (void) trace: (id) aFormat
  lineNumber: (int) lineNumber
    fileName: (char *) fileName
  methodName: (const char *) methodName,...;

+ (void) debug: (id) aFormat
    lineNumber: (int) lineNumber
      fileName: (char *) fileName
    methodName: (const char *) methodName,...;

+ (void) info: (id) aFormat
   lineNumber: (int) lineNumber
     fileName: (char *) fileName
   methodName: (const char *) methodName,...;

+ (void) warn: (id) aFormat
   lineNumber: (int) lineNumber
     fileName: (char *) fileName
   methodName: (const char *) methodName,...;

+ (void) error: (id) aFormat
    lineNumber: (int) lineNumber
      fileName: (char *) fileName
    methodName: (const char *) methodName,...;

+ (void) fatal: (id) aFormat
    lineNumber: (int) lineNumber
      fileName: (char *) fileName
    methodName: (const char *) methodName,...;

//private
+ (void) _logMsg:(NSString *)logMsg 
      lineNumber: (int) lineNumber
        fileName: (char *) fileName
      methodName: (const char *) methodName
         message: (id) aFormat;    


@end
