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

#import "PGRevealViewController.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

@interface PGRevealViewController ()

@end

@implementation PGRevealViewController

#pragma mark - Superview overrides

- (IBAction)unwindToReveal:(UIStoryboardSegue *)unwindSegue
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_PROVIDER_NOTIFICATION object:nil];
}

- (IBAction)dismissAnyModel:(UIStoryboardSegue *)segue
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
