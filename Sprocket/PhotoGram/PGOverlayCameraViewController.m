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

@interface PGOverlayCameraViewController ()

@property (weak, nonatomic) IBOutlet UIView *transitionEffectView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *shutterButton;
@property (assign) BOOL movieMode;
@property (assign) NSUInteger recordingTime;
@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;


@end

@implementation PGOverlayCameraViewController

- (void)viewDidLoad {
    self.movieMode = NO;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    
    if(velocity.x > 0) { // gesture to the right
        [self.shutterButton.imageView setImage: [UIImage imageNamed:@"cameraShutter"]];
        self.movieMode = NO;
    } else { // gesture to the left
        [self.shutterButton setImage:[UIImage imageNamed:@"cameraRecord"] forState:UIControlStateNormal];
        
        [self.shutterButton setImage:[UIImage imageNamed:@"cameraRecord"] forState:UIControlStateHighlighted];
        
        self.movieMode = YES;
    }
}
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
    if (self.movieMode) {
        if (![[PGCameraManager sharedInstance] isCapturingVideo]) {
            [[PGCameraManager sharedInstance] startRecording];
            self.recordingTime = 0;
            [NSTimer scheduledTimerWithTimeInterval: 1.0f target: self
                                           selector: @selector(updateTimeDisplay) userInfo: nil repeats: YES];
            [self.recordingTimeLabel setHidden:NO];
            [self.shutterButton setImage:[UIImage imageNamed:@"cameraStop"] forState:UIControlStateNormal];
            [self.shutterButton setImage:[UIImage imageNamed:@"cameraStop"] forState:UIControlStateHighlighted];
        } else {
            [self.recordingTimeLabel setHidden:YES];
            [[PGCameraManager sharedInstance] stopRecording];
        }
    } else {
        [[PGCameraManager sharedInstance] takePicture];
    }
}

- (void) updateTimeDisplay {
    _recordingTime += 1;

    int seconds = _recordingTime % 60;
    int minutes = (int) (_recordingTime - seconds) / 60;
    
    self.recordingTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
}

- (IBAction)flashTapped:(id)sender {
    [[PGCameraManager sharedInstance] toggleFlash];
    [self setupButtons];
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

@end
