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

#import "PGLandingNavigationController.h"
#import "MP.h"

NSString * const kHasLaunchedAppBefore = @"com.hp.hp-sprocket.hasLaunchedAppBefore";

@implementation PGLandingNavigationController

- (void)awakeFromNib
{
    [super awakeFromNib];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UIViewController *rootViewController;

    if ([self shouldShowWizard]) {
        rootViewController = [sb instantiateViewControllerWithIdentifier:@"IntroWizardScreen"];
    } else {
        rootViewController = [sb instantiateViewControllerWithIdentifier:@"LandingMainScreen"];
    }

    [self setViewControllers:@[rootViewController] animated:NO];
}

- (BOOL)shouldShowWizard
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (nil == [defaults objectForKey:kHasLaunchedAppBefore]) {
        [defaults setBool:YES forKey:kHasLaunchedAppBefore];
        [defaults synchronize];

        if ([[MP sharedInstance] numberOfPairedSprockets] == 0) {
            return YES;
        }
    }

    return NO;
}


@end
