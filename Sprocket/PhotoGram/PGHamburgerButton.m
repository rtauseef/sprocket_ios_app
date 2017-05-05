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

@interface PGHamburgerButton ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PGHamburgerButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkPrintQueue:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)checkPrintQueue:(NSTimer *)timer
{
    [self refreshIndicator];
}

- (void)refreshIndicator
{
    if ([MPBTPrintManager sharedInstance].queueSize > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:[UIImage imageNamed:@"hamburgerActive"] forState:UIControlStateNormal];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setImage:[UIImage imageNamed:@"hamburger"] forState:UIControlStateNormal];
        });
    }
}

@end
