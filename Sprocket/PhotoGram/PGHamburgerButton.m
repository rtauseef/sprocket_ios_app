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

#import "PGHamburgerButton.h"
#import <MPBTPrintManager.h>
#import <AirshipKit.h>

NSString * const kLastInboxMessageReceived = @"com.hp.hp-sprocket.LastInboxMessageReceived";

@interface PGHamburgerButton ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PGHamburgerButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkPrintQueue:) userInfo:nil repeats:YES];
        [self addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)checkPrintQueue:(NSTimer *)timer
{
    [self refreshIndicator];
}

- (void)refreshIndicator
{
    BOOL hasNewContent = [MPBTPrintManager sharedInstance].queueSize > 0;

    if (!hasNewContent) {
        UAInboxMessage *message = [[UAirship inbox].messageList.messages firstObject];

        if (message) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDate *lastMessageDate = [userDefaults objectForKey:kLastInboxMessageReceived];

            if (lastMessageDate) {
                hasNewContent = ([lastMessageDate compare:message.messageSent] == NSOrderedAscending);

            } else {
                hasNewContent = YES;
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (hasNewContent) {
            [self setImage:[UIImage imageNamed:@"hamburgerActive"] forState:UIControlStateNormal];
        } else {
            [self setImage:[UIImage imageNamed:@"hamburger"] forState:UIControlStateNormal];
        }
    });

}

- (void)buttonTapped
{
    UAInboxMessage *message = [[UAirship inbox].messageList.messages firstObject];

    if (message) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:message.messageSent forKey:kLastInboxMessageReceived];
        [userDefaults synchronize];

        [self refreshIndicator];
    }
}

@end
