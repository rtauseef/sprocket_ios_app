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
#import "PGAppNavigation.h"
#import "PGMediaNavigation.h"
#import "PGInboxMessageCenterListViewController.h"
#import "PGInboxMessageViewController.h"

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


#pragma mark - UAInboxDelegate

- (void)showInbox
{
    UIViewController *topViewController = [PGAppNavigation currentTopViewController];

    if ([topViewController isKindOfClass:[PGInboxMessageCenterListViewController class]]) {
        // already on inbox
        return;
    }

    if ([topViewController isKindOfClass:[PGInboxMessageViewController class]]) {
        // already on message view
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"PGMessageCenterNavigationController"];

    [topViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)richPushMessageAvailable:(UAInboxMessage *)richPushMessage
{
    [[PGMediaNavigation sharedInstance] updateNewContentIndicator];
}

@end
