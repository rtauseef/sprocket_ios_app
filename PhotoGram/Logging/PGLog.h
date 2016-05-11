//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <CocoaLumberjack/DDLogMacros.h>

// define our own logging context
#define PG_LOG_CONTEXT 1
#define MP_LOG_CONTEXT 2


/* The following has been left in since it is the better solution for handling logs from different sources.
 HOWEVER, since the [DDLog addLogger: withLevel:] call does not allow us to specify a given context,
 and we want to set our own log level seperately from the SVG pod, we must define a whole new set of log
 levels without re-using any bits.
 
 Please let me know if you know of a way to make this work that doesn't involve changing the Lumberjack
 code.
 */
//#define PG_LOG_FLAG (1 << 5)
//
//#define PG_LOG_FLAG_ERROR    PG_LOG_FLAG | LOG_FLAG_ERROR    // 0...00 0010 0001
//#define PG_LOG_FLAG_WARN     PG_LOG_FLAG | LOG_FLAG_WARN     // 0...00 0010 0010
//#define PG_LOG_FLAG_INFO     PG_LOG_FLAG | LOG_FLAG_INFO     // 0...00 0010 0100
//#define PG_LOG_FLAG_DEBUG    PG_LOG_FLAG | LOG_FLAG_DEBUG    // 0...00 0010 1000
//#define PG_LOG_FLAG_VERBOSE  PG_LOG_FLAG | LOG_FLAG_VERBOSE  // 0...00 0011 0000

/* Our unfortunate solution for handling logs from different sources */
#define PG_LOG_SHIFT 5

/**
 *  Flags accompany each log. They are used together with levels to filter out logs.
 */
typedef NS_OPTIONS(NSUInteger, PGLogFlag){
    /**
     *  0...00000 DDLogFlagError
     */
    PGLogFlagError      = (1 << PG_LOG_SHIFT),
    
    /**
     *  0...00001 DDLogFlagWarning
     */
    PGLogFlagWarning    = (1 << (PG_LOG_SHIFT+1)),
    
    /**
     *  0...00010 DDLogFlagInfo
     */
    PGLogFlagInfo       = (1 << (PG_LOG_SHIFT+2)),
    
    /**
     *  0...00100 DDLogFlagDebug
     */
    PGLogFlagDebug      = (1 << (PG_LOG_SHIFT+3)),
    
    /**
     *  0...01000 DDLogFlagVerbose
     */
    PGLogFlagVerbose    = (1 << (PG_LOG_SHIFT+4))
};
/* End of log-level definition workaround */

/**
 *  Log levels are used to filter out logs. Used together with flags.
 */
typedef NS_ENUM(NSUInteger, PGLogLevel){
    /**
     *  No logs
     */
    PGLogLevelOff       = 0,
    
    /**
     *  Error logs only
     */
    PGLogLevelError     = (PGLogFlagError),
    
    /**
     *  Error and warning logs
     */
    PGLogLevelWarning   = (PGLogLevelError   | PGLogFlagWarning),
    
    /**
     *  Error, warning and info logs
     */
    PGLogLevelInfo      = (PGLogLevelWarning | PGLogFlagInfo),
    
    /**
     *  Error, warning, info and debug logs
     */
    PGLogLevelDebug     = (PGLogLevelInfo    | PGLogFlagDebug),
    
    /**
     *  Error, warning, info, debug and verbose logs
     */
    PGLogLevelVerbose   = (PGLogLevelDebug   | PGLogFlagVerbose),
    
    /**
     *  All logs (1...11111)
     */
    PGLogLevelAll       = NSUIntegerMax
};

#define PGLogError(frmt, ...)     LOG_MAYBE(NO,                pgLogLevel, (DDLogFlag)PGLogFlagError,   PG_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PGLogWarn(frmt, ...)      LOG_MAYBE(LOG_ASYNC_ENABLED, pgLogLevel, (DDLogFlag)PGLogFlagWarning, PG_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PGLogInfo(frmt, ...)      LOG_MAYBE(LOG_ASYNC_ENABLED, pgLogLevel, (DDLogFlag)PGLogFlagInfo,    PG_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PGLogDebug(frmt, ...)     LOG_MAYBE(LOG_ASYNC_ENABLED, pgLogLevel, (DDLogFlag)PGLogFlagDebug,   PG_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PGLogVerbose(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, pgLogLevel, (DDLogFlag)PGLogFlagVerbose, PG_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define MPrintLogError(frmt, ...)     LOG_MAYBE(NO,                ddLogLevel, DDLogFlagError,   MP_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MPrintLogWarn(frmt, ...)      LOG_MAYBE(LOG_ASYNC_ENABLED, ddLogLevel, DDLogFlagWarning, MP_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MPrintLogInfo(frmt, ...)      LOG_MAYBE(LOG_ASYNC_ENABLED, ddLogLevel, DDLogFlagInfo,    MP_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MPrintLogDebug(frmt, ...)     LOG_MAYBE(LOG_ASYNC_ENABLED, ddLogLevel, DDLogFlagDebug,   MP_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define MPrintLogVerbose(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, ddLogLevel, DDLogFlagVerbose, MP_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
