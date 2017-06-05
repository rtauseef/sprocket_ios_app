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

#import "PGPrintQueueManager.h"
#import "PGInAppMessageManager.h"

#import <MP.h>
#import <MPBTPrintManager.h>


static NSString * const kPrintQueueManagerPrintCount = @"com.hp.hp-sprocket.printCount";
static NSInteger const kBuyPaperNotificationThresholdFirstTier  = 10;
static NSInteger const kBuyPaperNotificationThresholdSecondTier = 30;
static NSInteger const kBuyPaperNotificationThresholdThirdTier  = 50;

@interface PGPrintQueueManager ()

@property (weak, nonatomic) UIViewController *viewController;

@end


@implementation PGPrintQueueManager

+ (instancetype)sharedInstance
{
    static PGPrintQueueManager *instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGPrintQueueManager alloc] init];
    });

    return instance;
}

- (void)showPrintQueueStatusFromViewController:(UIViewController *)viewController
{
    [PGPrintQueueManager sharedInstance].viewController = viewController;

    MPBTPrinterManagerStatus status = [MPBTPrintManager sharedInstance].status;

    if (status != MPBTPrinterManagerStatusEmptyQueue || [MPBTPrintManager sharedInstance].queueSize > 0) {
        if ([[MP sharedInstance] numberOfPairedSprockets] == 0) {
            [[PGPrintQueueManager sharedInstance] showPrintQueueAlertNotConnected];
        } else {
            if (status == MPBTPrinterManagerStatusIdle) {
                [[PGPrintQueueManager sharedInstance] showPrintQueueAlertPaused];

            } else {
                [[PGPrintQueueManager sharedInstance] showPrintQueueAlertActive];
            }
        }
    } else {
        [[PGPrintQueueManager sharedInstance] showPrintQueueAlertEmpty];
    }
}

- (void)incrementPrintCounter
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];

    NSInteger count = [userdefaults integerForKey:kPrintQueueManagerPrintCount];
    count++;

    [userdefaults setInteger:count forKey:kPrintQueueManagerPrintCount];
    [userdefaults synchronize];

    if (count == kBuyPaperNotificationThresholdFirstTier ||
        count == kBuyPaperNotificationThresholdSecondTier ||
        count == kBuyPaperNotificationThresholdThirdTier)
    {
        [[PGInAppMessageManager sharedInstance] showBuyPaperMessage];
    }
}


#pragma mark - Private

- (NSString *)titleWithNumberOfPrints
{
    NSString *format;
    if ([MPBTPrintManager sharedInstance].queueSize == 1) {
        format = NSLocalizedString(@"%li print in Print Queue", @"Message presented when there is only one image in the print queue");
    } else {
        format = NSLocalizedString(@"%li prints in Print Queue", @"Message presented when there more than one images in the print queue");
    }

    return [NSString stringWithFormat:format, [MPBTPrintManager sharedInstance].queueSize];
}

- (void)deletePrintQueue
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete all prints from Print Queue?", nil)
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [[MPBTPrintManager sharedInstance] cancelPrintQueue];
                                                      }];
    [alertController addAction:yesAction];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No, Keep Them", nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:noAction];

    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertNotConnected
{
    NSString *title = [NSString stringWithFormat:@"%@,\n%@", [self titleWithNumberOfPrints], NSLocalizedString(@"Sprocket not Connected", nil)];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:NSLocalizedString(@"Photos will print in the order they were added to the Print Queue, after the sprocket printer is on and Bluetooth is connected.", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self deletePrintQueue];
                                                         }];
    [alertController addAction:deleteAction];

    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertEmpty
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No prints in Print Queue", @"Message title for when the print queue is empty")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];

    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertPaused
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self titleWithNumberOfPrints]
                                                                             message:NSLocalizedString(@"Photos will print in the order they were added to the Print Queue.", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self deletePrintQueue];
                                                         }];
    [alertController addAction:deleteAction];

    UIAlertAction *printAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Print", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [[MPBTPrintManager sharedInstance] resumePrintQueue:nil];
                                                        }];
    [alertController addAction:printAction];

    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

- (void)showPrintQueueAlertActive
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self titleWithNumberOfPrints]
                                                                             message:NSLocalizedString(@"Photos will print in the order they were added to the Print Queue.", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:okAction];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self deletePrintQueue];
                                                         }];
    [alertController addAction:deleteAction];

    [self.viewController presentViewController:alertController animated:YES completion:nil];
}

@end
