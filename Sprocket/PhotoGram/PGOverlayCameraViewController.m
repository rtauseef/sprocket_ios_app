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

#import "PGOverlayCameraViewController.h"
#import "PGCameraManager.h"

@implementation PGOverlayCameraViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.transitionEffectView.alpha == 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transitionEffectView.alpha = 0;
        }];
    }
}

- (IBAction)closeButtonTapped:(id)sender
{
    [[PGCameraManager sharedInstance] dismissCameraAnimated:YES completion:nil];
}

- (IBAction)cameraReverseTapped:(id)sender
{
    [[PGCameraManager sharedInstance] switchCamera];
}

- (IBAction)shutterTapped:(id)sender
{
    [[PGCameraManager sharedInstance] takePicture];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.transitionEffectView.alpha = 1;
    } completion:nil];
}

@end
