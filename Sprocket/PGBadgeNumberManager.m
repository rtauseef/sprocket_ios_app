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

#import <MP.h>
#import "PGBadgeNumberManager.h"

@implementation PGBadgeNumberManager

+ (PGBadgeNumberManager *)sharedManager
{
    static PGBadgeNumberManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobAddedToQueueNotification:) name:kMPPrintJobAddedToQueueNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobRemovedFromQueueNotification:) name:kMPPrintJobRemovedFromQueueNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAllPrintJobsRemovedFromQueueNotification:) name:kMPAllPrintJobsRemovedFromQueueNotification object:nil];
        
        [self setBadgeNumber];
    }
    return self;
}

- (void)setBadgeNumber
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[MP sharedInstance] numberOfJobsInQueue];
}

#pragma mark - Notifications

- (void)handlePrintJobAddedToQueueNotification:(NSNotification *)notification
{
    [self setBadgeNumber];
}

- (void)handlePrintJobRemovedFromQueueNotification:(NSNotification *)notification
{
    [self setBadgeNumber];
}

- (void)handleAllPrintJobsRemovedFromQueueNotification:(NSNotification *)notification
{
    [self setBadgeNumber];
}

@end
