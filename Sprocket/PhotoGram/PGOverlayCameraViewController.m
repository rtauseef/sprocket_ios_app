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

@interface PGOverlayCameraViewController ()

@end

@implementation PGOverlayCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonTapped:(id)sender {
    NSLog(@"close");
    [self.pickerReference dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)cameraReverseTapped:(id)sender {
    NSLog(@"reverse");
    [UIView transitionWithView:self.pickerReference.view duration:1.0 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        if (self.pickerReference.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else {
            self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } completion:NULL];
}

- (IBAction)shutterTapped:(id)sender {
    NSLog(@"shutter");
    [self.pickerReference takePicture];
}

@end
