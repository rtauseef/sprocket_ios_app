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
#import "PGLinkSettings.h"

#define kMaxRecordingTime (NSUInteger)20

@interface PGOverlayCameraViewController ()

@property (weak, nonatomic) IBOutlet UIView *transitionEffectView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *shutterButton;
@property (assign) BOOL movieMode;
@property (assign) float recordingTime;
@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (strong, nonatomic) CAShapeLayer *circle;
@property (strong, nonatomic) NSTimer *recordingTimer;
@end

@implementation PGOverlayCameraViewController

- (void)viewDidLoad {
    self.movieMode = NO;
    
    if ([PGLinkSettings videoPrintEnabled]) {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGesture.minimumPressDuration = 0.3f;
        
        [self.shutterButton addGestureRecognizer:longPressGesture];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // start recording
        if (![[PGCameraManager sharedInstance] isCapturingVideo]) {
            [[PGCameraManager sharedInstance] startRecording];
            self.recordingTime = 0;
            self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2f target: self
                                           selector: @selector(updateTimeDisplay) userInfo: nil repeats: YES];
            self.movieMode = YES;
        }
    } else if (self.movieMode && recognizer.state == UIGestureRecognizerStateEnded) {
        // stop recording
        [self.recordingTimer invalidate];
        [[PGCameraManager sharedInstance] stopRecording];
        self.movieMode = NO;
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
    if (!self.movieMode) {
        [[PGCameraManager sharedInstance] takePicture];
    }
}

- (void) updateTimeDisplay {
    _recordingTime += 0.2;

    if (_recordingTime >= kMaxRecordingTime) {
        [self.recordingTimer invalidate];
        [[PGCameraManager sharedInstance] stopRecording];
        return;
    }

    int radius = (int) self.shutterButton.bounds.size.width / 2;
    float startAngle = M_PI * -90 / 180;
    float endAngle;
    
    if (![[PGCameraManager sharedInstance] isCapturingVideo]) {
        [self.recordingTimer invalidate];
        self.movieMode = NO;
        endAngle = startAngle;
    } else {
        startAngle = M_PI * -90 / 180;
        endAngle = _recordingTime * ((M_PI * 360 / 180) / 20) + startAngle;
    }
    
    if (self.circle == nil) {
        self.circle = [CAShapeLayer layer];
        self.circle.position = CGPointMake(CGRectGetMidX(self.shutterButton.bounds)-radius,
                                      CGRectGetMidY(self.shutterButton.bounds)-radius);
        self.circle.fillColor = [UIColor clearColor].CGColor;
        self.circle.lineCap=kCALineCapRound;
        UIColor *strokeColor=[UIColor redColor];
        self.circle.strokeColor = strokeColor.CGColor;
        self.circle.lineWidth = 4;
        
        [self.shutterButton.layer addSublayer:self.circle];
    }
    
    UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.circle.path = [path CGPath];
    [self.circle setNeedsDisplay];
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
