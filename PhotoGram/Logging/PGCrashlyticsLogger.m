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

#import "PGCrashlyticsLogger.h"
#import <Crashlytics/Crashlytics.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@implementation PGCrashlyticsLogger

+ (id)sharedInstance
{
    static PGCrashlyticsLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PGCrashlyticsLogger alloc] init];
    });
    
    return sharedInstance;
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    CLSLog(@"%@", [_logFormatter formatLogMessage:logMessage]);
}

- (NSString *)loggerName
{
    return @"PGCrashlyticsLogger";
}

@end
