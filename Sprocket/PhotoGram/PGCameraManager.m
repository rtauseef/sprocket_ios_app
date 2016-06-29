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

#import "PGCameraManager.h"
#import "PGPreviewViewController.h"

@interface PGCameraManager ()

    @property (assign, nonatomic) BOOL isCameraOpened;

@end

@implementation PGCameraManager

+ (PGCameraManager *)sharedInstance
{
    static dispatch_once_t once;
    static PGCameraManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGCameraManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.isCameraOpened = NO;
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    self.picker.showsCameraControls = NO;
    self.picker.extendedLayoutIncludesOpaqueBars = NO;
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
    self.picker.cameraViewTransform = translate;
    
    CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
    self.picker.cameraViewTransform = scale;
    
    self.cameraOverlay = [[PGOverlayCameraViewController alloc] initWithNibName:@"PGOverlayCameraViewController" bundle:nil];
    
    self.cameraOverlay.pickerReference = self.picker;
    self.cameraOverlay.view.frame = self.picker.cameraOverlayView.frame;
    self.picker.delegate = self;
    self.picker.cameraOverlayView = self.cameraOverlay.view;
}

- (void)showCamera:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion
{
    self.viewController = viewController;
    [self.viewController presentViewController:self.picker animated:animated completion:completion];
}

- (void)dismissCameraAnimated:(BOOL)animated {
    [self.picker dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        picture = [UIImage imageWithCGImage:picture.CGImage scale:picture.scale orientation:UIImageOrientationLeftMirrored];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = picture;
    previewViewController.media = [[HPPRMedia alloc] initWithAttributes:info];
    previewViewController.source = @"CameraRoll";
    
    [self.picker dismissViewControllerAnimated:NO completion:^{
        if (self.viewController.presentingViewController) {
            [self.viewController.presentingViewController presentViewController:previewViewController animated:NO completion:nil];
        } else {
            [self.viewController presentViewController:previewViewController animated:NO completion:nil];
        }
    }];
    
}

- (void)mirrorImage {
}

@end
