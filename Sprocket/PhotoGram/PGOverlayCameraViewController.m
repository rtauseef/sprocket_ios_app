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

#import <AurasmaSDK/AurasmaSDK.h>
#import "PGCameraManager.h"
#import "PGAurasmaTrackingViewDelegate.h"
#import "PGAurasmaViewController.h"

#import "PGOverlayCameraViewController.h"

@interface PGOverlayCameraViewController () <PGAurasmaTrackingViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *transitionEffectView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *ARButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@end

@implementation PGOverlayCameraViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self setupButtons];
}

- (IBAction)closeButtonTapped:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerCameraClosed object:nil];
}

- (IBAction)cameraReverseTapped:(id)sender
{
    [[PGCameraManager sharedInstance] switchCamera];
    [self setupButtons];
}

- (IBAction)shutterTapped:(id)sender
{
    [[PGCameraManager sharedInstance] takePicture];
}

- (IBAction)flashTapped:(id)sender {
    [[PGCameraManager sharedInstance] toggleFlash];
    [self setupButtons];
}

- (IBAction)ARTapped:(id)sender {
    PGAurasmaViewController *aurasmaViewController = [[PGAurasmaViewController alloc] initWithNibName:@"PGAurasmaViewController" bundle:nil];
    [aurasmaViewController setClosingDelegate:self];
    _loadingView.hidden = NO;
    [self.view setNeedsDisplay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:aurasmaViewController animated:YES completion:nil];
    });
}

- (void)setupButtons
{
    NSArray<AVCaptureDevice *> *devices = [[PGCameraManager sharedInstance] availableDevices];

    if (devices.count <= 1) {
        self.switchCameraButton.hidden = YES;
    } else {
        self.switchCameraButton.hidden = NO;
    }

    if ([PGCameraManager sharedInstance].lastDeviceCameraPosition == AVCaptureDevicePositionFront) {
        self.flashButton.hidden = YES;
    } else {
        self.flashButton.hidden = NO;
        
        if ([PGCameraManager sharedInstance].isFlashOn) {
            [self.flashButton setImage:[UIImage imageNamed:@"cameraFlashOn"] forState:UIControlStateNormal];
        } else {
            [self.flashButton setImage:[UIImage imageNamed:@"cameraFlashOff"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark PGAurasmaTrackingViewDelegate

- (void)finishedTracking:(PGAurasmaViewController *)controller {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    /* Another AURTrackingController cannot be created until the previous one has finished releasing. */
    self.ARButton.hidden = YES;
    __block id <NSObject> observer;
    
    void (^notificationCallback)(NSNotification *) = ^(__unused NSNotification *notif) {
        [[PGCameraManager sharedInstance] resetPresetSize];
        self.ARButton.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            self.loadingView.hidden = YES;
        });
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        observer = nil; // Needed for iOS7
    };
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:AURDestroyTrackingControllerFinishedNotification
                                                                 object:[AURTrackingController class]
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:notificationCallback];
}

@end
