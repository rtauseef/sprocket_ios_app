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
    NSLog(@"PENDING MESSAGE");

    if ([self shouldDisplayMessage]) {
        [[UAirship inAppMessaging] displayPendingMessage];
    }
}

- (void)messageWillBeDisplayed:(UAInAppMessage *)message
{
    NSLog(@"MESSAGE WILL BE DISPLAYED");
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
