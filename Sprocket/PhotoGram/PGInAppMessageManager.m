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

#import "PGInAppMessageManager.h"
#import "PGAppNavigation.h"
#import "PGInAppMessageView.h"
#import "NSLocale+Additions.h"
#import "PGPartyManager.h"
#import "PGFeatureFlag.h"

#import <UIKit/UIKit.h>

NSString * const kInAppMessageTypeKey = @"message_type";
NSString * const kInAppMessageTypeValueBuyPaper = @"buy-paper";
NSString * const kInAppMessageTypeValueFirmwareUpgrade = @"firmware-upgrade";

@implementation PGInAppMessageManager

+ (instancetype)sharedInstance
{
    static PGInAppMessageManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGInAppMessageManager alloc] init];
    });

    return instance;
}

- (void)showBuyPaperMessage
{
    UAInAppMessage *message = [UAInAppMessage message];
    message.alert = NSLocalizedString(@"Hi, do you need more HP ZINK Photo Paper?", @"Buy paper notification message");
    message.buttonGroup = @"ua_buy_now";
    message.buttonActions = @{
                              @"buy_now": @{kUAOpenExternalURLActionDefaultRegistryAlias: @"http://www.hp.com/go/zinkphotopaper"}
                              };

    message.extra = @{kInAppMessageTypeKey: kInAppMessageTypeValueBuyPaper};

    [UAirship inAppMessaging].pendingMessage = message;
}

- (void)showFirmwareUpgradeMessage
{
    UAInAppMessage *message = [UAInAppMessage message];
    message.alert = NSLocalizedString(@"There is a firmware upgrade available for your sprocket printer.", @"Firmware update notification message");
    message.buttonGroup = @"ua_download";
    message.buttonActions = @{
                              // TODO: this is not the correct deep link. Should direct the user to the device screen. Deep link needs to be created
                              @"download": @{kUADeepLinkActionDefaultRegistryAlias: @"com.hp.sprocket.deepLinks://appSettings"}
                              };

    message.extra = @{kInAppMessageTypeKey: kInAppMessageTypeValueFirmwareUpgrade};

    [UAirship inAppMessaging].pendingMessage = message;
}

- (void)showPartyPhotoReceivedMessage
{
    UAInAppMessage *message = [UAInAppMessage message];
    NSString *alert = NSLocalizedString(@"Party photo received!", @"User received a photo from a party guest");
    NSString *queue = NSLocalizedString(@"Queued to print", @"Action description for adding to print queue");
    NSString *save = NSLocalizedString(@"Saved to photos", @"Action description for saving to camera roll folder");
    NSString *both = NSLocalizedString(@"Queue and saved", @"Action description for both adding to queue and saving to camera roll folder");
    if ([PGFeatureFlag isPartySaveEnabled] && [PGFeatureFlag isPartyPrintEnabled]) {
        alert = [NSString stringWithFormat:@"%@ %@", alert, both];
    } else if ([PGFeatureFlag isPartySaveEnabled]) {
        alert = [NSString stringWithFormat:@"%@ %@", alert, save];
    } else if ([PGFeatureFlag isPartyPrintEnabled]) {
        alert = [NSString stringWithFormat:@"%@ %@", alert, queue];
    }
    
    message.alert = alert;
    message.duration = 2.5;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UAirship inAppMessaging] displayMessage:message];
    });
}

- (void)attemptToDisplayPendingMessage
{
    if ([self shouldDisplayMessage]) {
        [[UAirship inAppMessaging] displayPendingMessage];
    }
}


#pragma mark - Private

- (BOOL)isRemoteBuyPaperMessage:(UAInAppMessage *)message
{
    BOOL titleMatch = [message.alert isEqualToString:@"Hi, do you need more HP ZINK Photo Paper?"];

    return titleMatch && message.extra == nil;
}

- (BOOL)shouldDisplayMessage
{
    BOOL allowsInAppMessages = NO;

    UIViewController *topViewController = [PGAppNavigation currentTopViewController];

    if ([topViewController respondsToSelector:@selector(allowsInAppMessages)]) {
        allowsInAppMessages = [(id<PGInAppMessageHost>)topViewController allowsInAppMessages];
    }

    allowsInAppMessages = allowsInAppMessages && ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive);

    return allowsInAppMessages;
}


#pragma mark - UAInAppMessagingDelegate

- (void)pendingMessageAvailable:(UAInAppMessage *)message
{
    if (![NSLocale isEnglish]) {
        [[UAirship inAppMessaging] deletePendingMessage:message];

    } else if ([self isRemoteBuyPaperMessage:message]) {
        [[UAirship inAppMessaging] deletePendingMessage:message];
        [self showBuyPaperMessage];

    } else if ([self shouldDisplayMessage]) {
        [[UAirship inAppMessaging] displayPendingMessage];
    }
}


#pragma mark - UAInAppMessageControllerDelegate

- (UIView *)viewForMessage:(UAInAppMessage *)message parentView:(UIView *)parentView
{
    PGInAppMessageView *messageView = [[PGInAppMessageView alloc] initWithMessage:message];

    [parentView addSubview:messageView];
    [messageView setupConstraints];

    [parentView layoutIfNeeded];
    [messageView layoutIfNeeded];

    return messageView;
}

- (UIControl *)messageView:(UIView *)messageView buttonAtIndex:(NSUInteger)index
{
    UIButton *button;

    if (index == 0) {
        button = ((PGInAppMessageView *)messageView).primaryButton;

    } else if (index == 1) {
        button = ((PGInAppMessageView *)messageView).secondaryButton;
    }

    return button;
}

- (void)messageView:(UIView *)messageView animateInWithParentView:(UIView *)parentView completionHandler:(void (^)(void))completionHandler
{
    [(PGInAppMessageView *) messageView show];

    [self animateMessageViewConstraints:messageView completionHandler:completionHandler];
}

- (void)messageView:(UIView *)messageView animateOutWithParentView:(UIView *)parentView completionHandler:(void (^)(void))completionHandler
{
    [(PGInAppMessageView *) messageView hide];

    [self animateMessageViewConstraints:messageView completionHandler:completionHandler];
}


#pragma mark - Private

- (void)animateMessageViewConstraints:(UIView *)messageView completionHandler:(void (^)(void))completionHandler
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [messageView.superview layoutIfNeeded];
        [messageView layoutIfNeeded];

    } completion:^(BOOL finished) {
        if (completionHandler) {
            completionHandler();
        }
    }];
}

@end
