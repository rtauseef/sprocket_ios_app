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

#import "PGLog.h"
#import <CocoaLumberjack.h>
#import <DDFileLogger.h>
#import <MPLogger.h>
#import <MessageUI/MessageUI.h>

extern int pgLogLevel;

extern int ddLogLevel;

@interface PGLogger : NSObject <MPLoggerDelegate>

@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (assign, nonatomic) BOOL hideSvgMessages;

+ (id)sharedInstance;

- (void)configureLogging;
- (void)cycleMailComposer;
- (MFMailComposeViewController *)globalMailComposer;
- (NSMutableArray *)errorLogData;

-(void)setDdLogLevel:(DDLogLevel)logLevel;
-(void)setPgLogLevel:(PGLogLevel)logLevel;

@end