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

#import "PGCameraLandingPageViewController.h"
#import "PGOverlayCameraViewController.h"

@interface PGCameraLandingPageViewController ()

@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) PGOverlayCameraViewController *overlay;

@end

@implementation PGCameraLandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    self.picker.showsCameraControls = NO;
    self.picker.extendedLayoutIncludesOpaqueBars = NO;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0); //This slots the preview exactly in the middle of the screen by moving it down 71 points
    self.picker.cameraViewTransform = translate;
    
    CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
    self.picker.cameraViewTransform = scale;
    
    // Insert the overlay
    self.overlay = [[PGOverlayCameraViewController alloc] initWithNibName:@"PGOverlayCameraViewController" bundle:nil];
    
    self.overlay.pickerReference = self.picker;
    self.overlay.view.frame = self.picker.cameraOverlayView.frame;
    self.picker.delegate = self.overlay;
    
    [self presentViewController:self.picker animated:YES completion:^{
        self.picker.cameraOverlayView = self.overlay.view;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
