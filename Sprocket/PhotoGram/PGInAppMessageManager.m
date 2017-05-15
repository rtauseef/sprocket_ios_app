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

    [[UAirship inAppMessaging] displayMessage:message];
}

- (void)showFirmwareUpgradeMessage
{
    UAInAppMessage *message = [UAInAppMessage message];
    message.alert = NSLocalizedString(@"There is a firmware upgrade available for your sprocket printer.", @"Firmware update notification message");
    message.buttonGroup = @"ua_download"; // Don't need a "Not now" button?
    message.buttonActions = @{
                              // TODO: this is not the correct deep link. Should direct the user to the device screen. Deep link needs to be created
                              @"download": @{kUADeepLinkActionDefaultRegistryAlias: @"com.hp.sprocket.deepLinks://appSettings"}
                              };

    message.extra = @{kInAppMessageTypeKey: kInAppMessageTypeValueFirmwareUpgrade};

    [[UAirship inAppMessaging] displayMessage:message];
}


#pragma mark - Private

- (BOOL)shouldDisplayMessage
{
    BOOL allowsInAppMessages = NO;

    UIViewController *topViewController = [PGAppNavigation currentTopViewController];

    if ([topViewController respondsToSelector:@selector(allowsInAppMessages)]) {
        allowsInAppMessages = [(id<PGInAppMessageHost>)topViewController allowsInAppMessages];
    }

    return allowsInAppMessages;
}


#pragma mark - UAInAppMessagingDelegate

- (void)pendingMessageAvailable:(UAInAppMessage *)message
{
    if ([self shouldDisplayMessage]) {
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
