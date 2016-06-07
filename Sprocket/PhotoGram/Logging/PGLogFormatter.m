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

#import <libkern/OSAtomic.h>

#import <DDTTYLogger.h>
#import "PGLogFormatter.h"
#import "PGLogger.h"
#import "PGLog.h"

@interface PGLogFormatter()

@property (strong, nonatomic) NSString *dateFormat;
@property (strong, nonatomic) NSString *appName;

@end

@implementation PGLogFormatter

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    
    [self configureLogColors];
    self.dateFormat = @"yyyy-MM-dd hh:mm:ss:SSS";
    self.appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    return self;
}

- (void)didAddToLogger:(id <DDLogger>)logger
{
    OSAtomicIncrement32(&atomicLoggerCount);
}
- (void)willRemoveFromLogger:(id <DDLogger>)logger
{
    OSAtomicDecrement32(&atomicLoggerCount);
}

#pragma mark - Log Message

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *outputMsg = nil;
    
    NSString *logLevel;
    switch ((logMessage->_flag & DDLogLevelVerbose) | (logMessage->_flag & PGLogLevelVerbose))
    {
        case DDLogFlagError:
        case PGLogFlagError:
            logLevel = @"Error";
            break;
            
        case DDLogFlagWarning:
        case PGLogFlagWarning:
            logLevel = @"Warn ";
            break;
            
        case DDLogFlagInfo:
        case PGLogFlagInfo:
            logLevel = @"Info ";
            break;
            
        case DDLogFlagDebug:
        case PGLogFlagDebug:
            logLevel = @"Debug";
            break;
            
        default:
            logLevel = @"Verb ";
            break;
    }
    
    NSString *dateAndTime = [self stringFromDate:(logMessage->_timestamp)];
    NSString *logMsg = logMessage->_message;
    
    if( PG_LOG_CONTEXT == logMessage->_context ) {
        outputMsg = [NSString stringWithFormat:@"%@ %@ %@ | %@\n", self.appName, logLevel, dateAndTime, logMsg];
        
    } else if( MP_LOG_CONTEXT == logMessage->_context ) {
        
        // We can't affect the ddLogLevel of PODs (without making some additions and modifications to their code).
        //  Therefore, we consider the verbosity of their logging to be a formatting issue instead of a log-level issue.
        //  If we want full control over their log levels, set their internal ddLogLevel to verbose and throttle the level
        //  of logging we see using our definition of ddLogLevel.
        if( logMessage->_flag <= ddLogLevel ) {
            outputMsg = [NSString stringWithFormat:@"HPPhotoPrint %@ %@ | %@\n", logLevel, dateAndTime, logMsg];
        }
    } else if( 0 == logMessage->_context ) {
        // We can't affect the ddLogLevel of PODs (without making some additions and modifications to their code).
        //  Therefore, we consider the verbosity of their logging to be a formatting issue instead of a log-level issue.
        //  If we want full control over their log levels, set their internal ddLogLevel to verbose and throttle the level
        //  of logging we see using our definition of ddLogLevel.

        // SVG messages are a special case
        if( [[PGLogger sharedInstance] hideSvgMessages]  &&  [logMessage->_message containsString:@"[SVG"] ) {
            // do nothing
        }
        else if( logMessage->_flag <= ddLogLevel ) {
            outputMsg = [NSString stringWithFormat:@"defaultCtxt %@ %@ | %@\n", logLevel, dateAndTime, logMsg];
        }
        
    } else {
        outputMsg = [NSString stringWithFormat:@"unrecognized ctxt: %ld %@ %@ | %@\n", (long)logMessage->_context, logLevel, dateAndTime, logMsg];
    }
    
    return outputMsg;
}

#pragma mark - Helpers

- (NSString *)stringFromDate:(NSDate *)date
{
    int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCount);
    
    if (loggerCount <= 1)
    {
        // Single-threaded mode.
        
        if (threadUnsafeDateFormatter == nil)
        {
            threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
            [threadUnsafeDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [threadUnsafeDateFormatter setDateFormat:self.dateFormat];
        }
        
        return [threadUnsafeDateFormatter stringFromDate:date];
    }
    else
    {
        // Multi-threaded mode.
        // NSDateFormatter is NOT thread-safe.
        
        NSString *key = @"MyCustomFormatter_NSDateFormatter";
        
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];
        
        if (dateFormatter == nil)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [dateFormatter setDateFormat:self.dateFormat];
            
            [threadDictionary setObject:dateFormatter forKey:key];
        }
        
        return [dateFormatter stringFromDate:date];
    }
}

- (void)configureLogDefaultColors
{
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];  // See: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/XcodeColors.md
    
    // Color code our PhotoGram log statements
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *errorColor      = [UIColor redColor];
    UIColor *warningColor    = [UIColor orangeColor];
    UIColor *infoColor       = [UIColor blackColor];
    UIColor *debugColor      = [UIColor blackColor];
    UIColor *verboseColor    = [UIColor blackColor];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:errorColor backgroundColor:backgroundColor forFlag:DDLogFlagError];
    [[DDTTYLogger sharedInstance] setForegroundColor:warningColor backgroundColor:backgroundColor forFlag:DDLogFlagWarning];
    [[DDTTYLogger sharedInstance] setForegroundColor:infoColor backgroundColor:backgroundColor forFlag:DDLogFlagInfo];
    [[DDTTYLogger sharedInstance] setForegroundColor:debugColor backgroundColor:backgroundColor forFlag:DDLogFlagDebug];
    [[DDTTYLogger sharedInstance] setForegroundColor:verboseColor backgroundColor:backgroundColor forFlag:DDLogFlagVerbose];

    backgroundColor = [UIColor colorWithRed:0.75f green:1.0f blue:1.0f alpha:1.0f];
    [[DDTTYLogger sharedInstance] setForegroundColor:errorColor backgroundColor:backgroundColor forFlag:DDLogFlagError context:MP_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:warningColor backgroundColor:backgroundColor forFlag:DDLogFlagWarning context:MP_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:infoColor backgroundColor:backgroundColor forFlag:DDLogFlagInfo context:MP_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:debugColor backgroundColor:backgroundColor forFlag:DDLogFlagDebug context:MP_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:verboseColor backgroundColor:backgroundColor forFlag:DDLogFlagVerbose context:MP_LOG_CONTEXT];
}

- (void)configureLogPhotogramColors
{
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];  // See: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/XcodeColors.md
    
    // Color code our PhotoGram log statements
    UIColor *backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.75f alpha:1.0f];
    UIColor *errorColor      = [UIColor redColor];
    UIColor *warningColor    = [UIColor orangeColor];
    UIColor *infoColor       = [UIColor colorWithRed:0.0f green:0.36f blue:0.11f alpha:1.0f];
    UIColor *debugColor      = [UIColor blueColor];
    UIColor *verboseColor    = [UIColor blackColor];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:errorColor backgroundColor:backgroundColor forFlag:(DDLogFlag)PGLogFlagError context:PG_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:warningColor backgroundColor:backgroundColor forFlag:(DDLogFlag)PGLogFlagWarning context:PG_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:infoColor backgroundColor:backgroundColor forFlag:(DDLogFlag)PGLogFlagInfo context:PG_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:debugColor backgroundColor:backgroundColor forFlag:(DDLogFlag)PGLogFlagDebug context:PG_LOG_CONTEXT];
    [[DDTTYLogger sharedInstance] setForegroundColor:verboseColor backgroundColor:backgroundColor forFlag:(DDLogFlag)PGLogFlagVerbose context:PG_LOG_CONTEXT];
}

- (void)configureLogColors
{
    [self configureLogDefaultColors];
    [self configureLogPhotogramColors];
}

#pragma mark - Testing

+ (void)demoAllFormats
{
    // custom context log statements
    PGLogError(@"Test log statement");
    PGLogWarn(@"Test log statement");
    PGLogInfo(@"Test log statement");
    PGLogDebug(@"Test log statement");
    PGLogVerbose(@"Test log statement");
    
    // standard log statements
    DDLogError(@"Test log statement");
    DDLogWarn(@"Test log statement");
    DDLogInfo(@"Test log statement");
    DDLogDebug(@"Test log statement");
    DDLogVerbose(@"Test log statement");
}

@end