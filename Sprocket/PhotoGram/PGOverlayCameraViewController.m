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
#import <AVKit/AVKit.h>

#define kMaxRecordingTime (NSUInteger)20
#define kScanningCircleRadius 180.0
#define kScanningCircleBorder 3
#define kLineDashPattern @[[NSNumber numberWithInt:20],[NSNumber numberWithInt:40]]
#define kSpinnerCircleSpeed 2.0f

@interface PGOverlayCameraViewController ()

@property (weak, nonatomic) IBOutlet UIView *transitionEffectView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *shutterButton;
@property (assign) BOOL movieMode;
@property (assign) float recordingTime;
@property (strong, nonatomic) NSTimer *recordingTimer;


@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recordingProgressViewHeight;
@property (weak, nonatomic) IBOutlet UIView *recordingContainerView;
@property (weak, nonatomic) IBOutlet UIProgressView *recordingProgressView;

@property (assign, nonatomic) BOOL playbackMode;
@property (assign, nonatomic) BOOL watermarkingEnabled;

@property (strong, nonatomic) AVURLAsset *playbackAsset;
@property (strong, nonatomic) UIImage *playbackImage;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;

@end

@implementation PGOverlayCameraViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"Created new camera overlay");
    }
    return self;
}

- (void) onResume {
     [[PGCameraManager sharedInstance] stopScanning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.movieMode = NO;
    
    if ([PGLinkSettings linkEnabled]) {
        self.watermarkingEnabled = NO;
        [[PGCameraManager sharedInstance] runAuthorization];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.playbackMode = NO;
    self.recordingProgressViewHeight.constant = 0.0f;
    self.recordingProgressView.hidden = YES;
    self.scanView.hidden = YES;
    [self.shutterButton setImage:[UIImage imageNamed:@"cameraShutter"] forState:UIControlStateNormal];
    
    if ([PGLinkSettings videoPrintEnabled]) {
        UILongPressGestureRecognizer *longPressGestureForShutter = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressShutterButton:)];
        longPressGestureForShutter.minimumPressDuration = 0.3f;
        [self.shutterButton addGestureRecognizer:longPressGestureForShutter];
    }
    
    if ([PGLinkSettings linkEnabled]) {
        UILongPressGestureRecognizer *longPressGestureForScreen = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressScreen:)];
        longPressGestureForScreen.minimumPressDuration = 0.3f;
        [self.view addGestureRecognizer:longPressGestureForScreen];
    }

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onResume)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScanning];
    
    if ([PGLinkSettings videoPrintEnabled]) {
        if ([[self.shutterButton gestureRecognizers] count] > 0) {
            [self.shutterButton removeGestureRecognizer:[[self.shutterButton gestureRecognizers] firstObject]];
        }
    }
    
    if ([PGLinkSettings linkEnabled]) {
        if ([[self.view gestureRecognizers] count] > 0) {
            [self.view removeGestureRecognizer:[[self.view gestureRecognizers] firstObject]];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) enableLinkWatermarking {
    self.watermarkingEnabled = YES;
}

- (void) handleLongPressScreen:(UILongPressGestureRecognizer *)recognizer {
    if (!_watermarkingEnabled) {
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                    message:NSLocalizedString(@"Image scanning is not available at this time. Please try again later.", @"Message shown when the user tries to scan an image and the scanning service is not available")
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OK", @"Button caption")
                          otherButtonTitles:nil] show];
        
        }
        
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan && !self.movieMode) {
        
        [self.scanView setAlpha:0];
        [self.scanView setHidden:NO];
        
        self.closeButton.hidden = YES;
        self.shutterButton.hidden = YES;
        self.flashButton.hidden = YES;
        self.switchCameraButton.hidden = YES;
        
        // fade in
        [UIView animateWithDuration:1.0f animations:^{
            self.scanView.alpha = 1;
        } completion:^(BOOL finished) {
            [[PGCameraManager sharedInstance] startScanning];
        }];
    }  else if (recognizer.state == UIGestureRecognizerStateEnded && !self.movieMode) {
        
        // fade out
        [UIView animateWithDuration:1.0f animations:^{
            self.scanView.alpha = 0;
        } completion:^(BOOL finished) {
            [[PGCameraManager sharedInstance] stopScanning];
            [self stopScanning];
        }];
        
    }
}

- (void) stopScanning {
    self.scanView.hidden = YES;
    self.closeButton.hidden = NO;
    self.shutterButton.hidden = NO;
    self.flashButton.hidden = NO;
    self.switchCameraButton.hidden = NO;
}

- (void) playVideo: (AVURLAsset *) asset image: (UIImage *) image {
    [self.shutterButton setImage:[UIImage imageNamed:@"videoNext"] forState:UIControlStateNormal];
    self.playbackMode = YES;
    self.playbackAsset = asset;
    self.playbackImage = image;
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
    
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    self.playerViewController = [AVPlayerViewController new];
    self.playerViewController.player = self.player;
    self.playerViewController.view.backgroundColor = [UIColor clearColor];
    self.playerViewController.view.frame = self.view.bounds;
    self.playerViewController.showsPlaybackControls = NO;
    [self.view insertSubview:self.playerViewController.view atIndex:0];
    [self.player play];
};

- (void) playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)handleLongPressShutterButton:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // start recording
        if (![[PGCameraManager sharedInstance] isCapturingVideo]) {
            [[PGCameraManager sharedInstance] startRecording];
            self.recordingTime = 0;
            self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2f target: self
                                           selector: @selector(updateTimeDisplay) userInfo: nil repeats: YES];
            self.movieMode = YES;
            
            [self.recordingProgressView setProgress:0.0];
            //self.recordingContainerView.hidden = NO;
            self.recordingProgressView.hidden = NO;
            _recordingProgressViewHeight.constant = 30.0f;
            
            [self.shutterButton setImage:[UIImage imageNamed:@"videoRecord"] forState:UIControlStateNormal];
            
            
            [self.view setNeedsLayout];
        }
    } else if (self.movieMode && recognizer.state == UIGestureRecognizerStateEnded) {
        // stop recording
        [self.recordingTimer invalidate];
        [[PGCameraManager sharedInstance] stopRecording];
        self.movieMode = NO;
        [self.shutterButton setImage:[UIImage imageNamed:@"cameraShutter"] forState:UIControlStateNormal];
        
        self.recordingProgressViewHeight.constant = 0.0f;
        self.recordingProgressView.hidden = YES;
        //self.recordingContainerView.hidden = YES;
        [self.recordingContainerView setNeedsLayout];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self setupButtons];
}

- (IBAction)closeButtonTapped:(id)sender
{
    if (!self.playbackMode) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerCameraClosed object:nil];
    } else {
        self.playbackMode = NO;
        [self.shutterButton setImage:[UIImage imageNamed:@"cameraShutter"] forState:UIControlStateNormal];
        [self.player pause];
        [self.playerViewController.view removeFromSuperview];
    }
}

- (IBAction)cameraReverseTapped:(id)sender
{
    [[PGCameraManager sharedInstance] switchCamera];
    [self setupButtons];
}

- (IBAction)shutterTapped:(id)sender
{
    if (!self.movieMode && !self.playbackMode) {
        [[PGCameraManager sharedInstance] takePicture];
    } else if (!self.movieMode && self.playbackMode) {
        [self.player pause];
        [self.playerViewController.view removeFromSuperview];

        [[PGCameraManager sharedInstance] loadPreviewViewControllerWithVideo:_playbackAsset andImage:_playbackImage andInfo:nil];
    }
}

- (void) updateTimeDisplay {
    _recordingTime += 0.2;

    [self.recordingProgressView setProgress:_recordingTime/20];
    
    if (_recordingTime >= kMaxRecordingTime) {
        [self.recordingTimer invalidate];
        [[PGCameraManager sharedInstance] stopRecording];
        return;
    }

    /*int radius = (int) self.shutterButton.bounds.size.width / 2;
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
    [self.circle setNeedsDisplay];*/
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

- (void)dealloc
{
    NSLog(@"PG overlay is being dealloced");
}

@end
