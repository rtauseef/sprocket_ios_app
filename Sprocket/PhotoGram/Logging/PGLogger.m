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

#import "PGLogger.h"

// Hi James!  This is where you turn it all off :-)
#ifdef DEBUG
int pgLogLevel = PGLogLevelVerbose;
int ddLogLevel = DDLogLevelVerbose;
#else
int pgLogLevel = PGLogLevelInfo;
int ddLogLevel = DDLogLevelInfo;
#endif

#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import "PGLogger.h"
#import "PGLogFormatter.h"
#import "PGCrashlyticsLogger.h"

static MFMailComposeViewController *mailViewController;

static NSString * const kDdLogLevel      = @"ddLogLevel";
static NSString * const kPgLogLevel      = @"pgLogLevel";
static NSString * const kHideSvgMessages = @"hideSvgMessages";

@interface PGLogger()

@end

@implementation PGLogger

+ (id)sharedInstance
{
    static PGLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PGLogger alloc] init];
    });
    
    return sharedInstance;
}

- (void)configureLogging
{
    // Customize the format of the log statements
    PGLogFormatter *logFormatter = [[PGLogFormatter alloc] init];
    [[DDASLLogger sharedInstance] setLogFormatter:logFormatter]; // for Console.app
    [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter]; // for the XCode console
    [[PGCrashlyticsLogger sharedInstance] setLogFormatter:logFormatter];
    
    // Which log level(s) should be included in the logs?
    [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:DDLogLevelVerbose | PGLogLevelVerbose];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelVerbose | PGLogLevelVerbose];
    [DDLog addLogger:[PGCrashlyticsLogger sharedInstance] withLevel:DDLogLevelVerbose | PGLogLevelVerbose];
    
    // Create the log file
    self.fileLogger = [[DDFileLogger alloc] init];
    [self.fileLogger setLogFormatter:logFormatter];
    [self.fileLogger setMaximumFileSize:(1024 * 1024)]; // no bigger than 1 MB
    
    self.fileLogger.rollingFrequency = 0; // the file will not be rolled based on time constraints
    
    [[self.fileLogger logFileManager] setMaximumNumberOfLogFiles:1]; // only one log file at any given time (no compressing and saving when the time or size limit is reached)
    
    [DDLog addLogger:self.fileLogger withLevel:DDLogLevelVerbose | PGLogLevelVerbose];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil != [defaults objectForKey:kDdLogLevel]) {
        ddLogLevel = (int)[defaults integerForKey:kDdLogLevel];
    }
    
    if (nil != [defaults objectForKey:kPgLogLevel]) {
        pgLogLevel = (int)[defaults integerForKey:kPgLogLevel];
    }
    
    [[MPLogger sharedInstance] setDelegate:self];
    
    [PGLogFormatter demoAllFormats];
}

-(void)setDdLogLevel:(DDLogLevel)logLevel
{
    ddLogLevel = (int)logLevel;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:ddLogLevel forKey:kDdLogLevel];
    [defaults synchronize];
}

-(void)setPgLogLevel:(PGLogLevel)logLevel
{
    pgLogLevel = (int)logLevel;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:pgLogLevel forKey:kPgLogLevel];
    [defaults synchronize];
}

- (NSMutableArray *)errorLogData
{
    NSUInteger maximumLogFilesToReturn = self.fileLogger.logFileManager.maximumNumberOfLogFiles;
    NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
    
    NSArray *sortedLogFileInfos = [self.fileLogger.logFileManager sortedLogFileInfos];
    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i++) {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        [errorLogFiles addObject:fileData];
    }
    return errorLogFiles;
}

#pragma mark - Mail Composer

- (void)cycleMailComposer
{
    mailViewController = nil;
    mailViewController = [[MFMailComposeViewController alloc] init];
}

- (MFMailComposeViewController *)globalMailComposer
{
    return mailViewController;
}

#pragma mark - Hide SVG Messages

-(void)setHideSvgMessages:(BOOL)hideMessages
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:hideMessages forKey:kHideSvgMessages];
    [defaults synchronize];
}

-(BOOL)hideSvgMessages
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL retVal = [defaults boolForKey:kHideSvgMessages];
    return retVal;
}

#pragma mark - MPLoggerDelegate

- (void) logError:(NSString*)msg
{
    MPrintLogError(@"%@", msg);
}

- (void) logWarn:(NSString*)msg
{
    MPrintLogWarn(@"%@", msg);
}

- (void) logInfo:(NSString*)msg
{
    MPrintLogInfo(@"%@", msg);
}

- (void) logDebug:(NSString*)msg
{
    MPrintLogDebug(@"%@", msg);
}

- (void) logVerbose:(NSString*)msg
{
    MPrintLogVerbose(@"%@", msg);
}

@end
