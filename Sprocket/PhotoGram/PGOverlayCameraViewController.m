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

- (IBAction)closeButtonTapped:(id)sender
{
    [[PGCameraManager sharedInstance] dismissCameraAnimated:YES];
}

- (IBAction)cameraReverseTapped:(id)sender
{
    [UIView transitionWithView:self.pickerReference.view duration:1.0 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        if (self.pickerReference.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else {
            self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } completion:NULL];
}

- (IBAction)shutterTapped:(id)sender
{
    [self.pickerReference takePicture];
}

@end
