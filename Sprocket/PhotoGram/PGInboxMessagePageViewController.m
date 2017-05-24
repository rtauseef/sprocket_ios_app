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

#import "PGInboxMessagePageViewController.h"
#import "PGInboxMessageViewController.h"
#import "UIColor+Style.h"

@interface PGInboxMessagePageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@end

@implementation PGInboxMessagePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
    self.dataSource = self;

    self.view.backgroundColor = [UIColor HPDarkBackgroundColor];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];

    self.navigationItem.leftBarButtonItem = backButton;

    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(deleteButtonTapped)];

    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)setFocusedMessageIndex:(NSInteger)focusedMessageIndex
{
    if (focusedMessageIndex < self.messages.count) {
        UAInboxMessage *message = [self.messages objectAtIndex:focusedMessageIndex];

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        PGInboxMessageViewController *viewController = (PGInboxMessageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGInboxMessageViewController"];
    
        viewController.message = message;

        [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

        self.title = [message title];
    }
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    UAInboxMessage *message = [((PGInboxMessageViewController *)[pendingViewControllers firstObject]) message];

    self.title = [message title];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UAInboxMessage *message = [((PGInboxMessageViewController *)[self.viewControllers firstObject]) message];

    self.title = [message title];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PGInboxMessageViewController *newViewController;

    NSInteger messageIndex = [self indexForMessage:((PGInboxMessageViewController *)viewController).message];

    if (messageIndex != NSNotFound) {
        messageIndex--;

        newViewController = [self messageViewControllerWithMessageIndex:messageIndex];
    }

    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PGInboxMessageViewController *newViewController;

    NSInteger messageIndex = [self indexForMessage:((PGInboxMessageViewController *)viewController).message];

    if (messageIndex != NSNotFound) {
        messageIndex++;

        newViewController = [self messageViewControllerWithMessageIndex:messageIndex];
    }

    return newViewController;
}


#pragma mark - Private

- (NSInteger)indexForMessage:(UAInboxMessage *)message
{
    for (NSInteger i = 0; i < self.messages.count; i++) {
        if ([message.messageID isEqualToString:self.messages[i].messageID]) {
            return i;
        }
    }

    return NSNotFound;
}

- (PGInboxMessageViewController *)messageViewControllerWithMessageIndex:(NSInteger)messageIndex
{
    PGInboxMessageViewController *newViewController;

    if (messageIndex >= 0 && messageIndex < self.messages.count) {
        UAInboxMessage *message = [self.messages objectAtIndex:messageIndex];

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        newViewController = (PGInboxMessageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGInboxMessageViewController"];

        newViewController.message = message;
    }

    return newViewController;
}

- (void)backButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonTapped
{
    UAInboxMessage *message = [((PGInboxMessageViewController *)[self.viewControllers firstObject]) message];

    if (message) {
        NSInteger messageIndex = [self indexForMessage:message];
        UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;

        if (messageIndex == self.messages.count - 1) {
            direction = UIPageViewControllerNavigationDirectionReverse;
            messageIndex--;

        } else {
            messageIndex++;
        }

        [[UAirship inbox].messageList markMessagesDeleted:@[message] completionHandler:^{
            PGInboxMessageViewController *viewController = [self messageViewControllerWithMessageIndex:messageIndex];

            if (viewController) {
                [self setViewControllers:@[viewController] direction:direction animated:YES completion:nil];
                self.title = [viewController.message title];

            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }

            self.messages = [NSArray arrayWithArray:[UAirship inbox].messageList.messages];
        }];
    }
}

@end
