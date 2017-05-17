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

#import "PGInboxMessageManager.h"
#import <AirshipKit.h>

@implementation PGInboxMessageManager

+ (instancetype)sharedInstance
{
    static PGInboxMessageManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGInboxMessageManager alloc] init];
    });

    return instance;
}

- (BOOL)hasUnreadMessages
{
    return [[UAirship inbox] messageList].unreadCount > 0;
}

@end
