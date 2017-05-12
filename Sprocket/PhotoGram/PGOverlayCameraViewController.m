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
@property (weak, nonatomic) IBOutlet UILabel *recordingTimeLabel;
@property (strong, nonatomic) CAShapeLayer *circle;
@property (strong, nonatomic) NSTimer *recordingTimer;

@property (strong, nonatomic) NSTimer *scanningTimer;
@property (strong, nonatomic) CAShapeLayer *scanningCircle;
@property (strong, nonatomic) CAShapeLayer *yelloCircle;
@property (strong, nonatomic) UIView *overlay;

@property (assign, nonatomic) BOOL watermarkingEnabled;

@end

@implementation PGOverlayCameraViewController

- (void)viewDidLoad {
    self.movieMode = NO;
    
    if ([PGLinkSettings videoPrintEnabled]) {
        UILongPressGestureRecognizer *longPressGestureForShutter = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressShutterButton:)];
        longPressGestureForShutter.minimumPressDuration = 0.3f;
        [self.shutterButton addGestureRecognizer:longPressGestureForShutter];
    }
    
    if ([PGLinkSettings linkEnabled]) {
        self.watermarkingEnabled = NO;
        [[PGCameraManager sharedInstance] runAuthorization];
        
        UILongPressGestureRecognizer *longPressGestureForScreen = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressScreen:)];
        longPressGestureForScreen.minimumPressDuration = 0.3f;
        [self.view addGestureRecognizer:longPressGestureForScreen];
    }
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
        self.scanningTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2f target: self
                                                             selector: @selector(updateScanning) userInfo: nil repeats: YES];
    }  else if (recognizer.state == UIGestureRecognizerStateEnded && !self.movieMode) {
        
        [self stopScanning];
    }
}

- (void) stopScanning {
    if (self.scanningTimer)
        [self.scanningTimer invalidate];
    
    if (self.scanningCircle) {
        [self.scanningCircle removeFromSuperlayer];
        self.scanningCircle = nil;
    }
    
    if (self.yelloCircle) {
        [self.yelloCircle removeFromSuperlayer];
        self.yelloCircle = nil;
    }
    
    if (self.overlay) {
        [self.overlay removeFromSuperview];
        self.overlay = nil;
    }
    
    [[PGCameraManager sharedInstance] stopScanning];
}

- (void) updateScanning {
    
    if (self.scanningCircle == nil) {
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self.overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        
        self.scanningCircle = [CAShapeLayer layer];
        self.scanningCircle.frame = self.overlay.bounds;
        self.scanningCircle.fillColor = [UIColor blackColor].CGColor;
        
        float initialRadius = kScanningCircleRadius * 4;
        
        CGRect rect = CGRectMake(CGRectGetMidX(self.overlay.frame) - initialRadius, CGRectGetMidY(self.overlay.frame) - initialRadius
                                 , 2 * initialRadius, 2 * initialRadius);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.overlay.bounds];
        self.scanningCircle.fillRule = kCAFillRuleEvenOdd;
        [path appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
        
        self.scanningCircle.path = path.CGPath;
        self.overlay.layer.mask = self.scanningCircle;
        
        [CATransaction begin];
        
        float finalRadius = kScanningCircleRadius;
        
        CGRect finalRect = CGRectMake(CGRectGetMidX(self.overlay.frame) - finalRadius, CGRectGetMidY(self.overlay.frame) - finalRadius
                                 , 2 * finalRadius, 2 * finalRadius);
        
        UIBezierPath *newPath = [UIBezierPath bezierPathWithRect:self.overlay.bounds];
        [newPath appendPath:[UIBezierPath bezierPathWithOvalInRect:finalRect]];
        
        CABasicAnimation* pathAnim = [CABasicAnimation animationWithKeyPath: @"path"];
        pathAnim.toValue = (id)newPath.CGPath;
        CAAnimationGroup *anims = [CAAnimationGroup animation];
        anims.removedOnCompletion = NO;
        anims.duration = 0.3f;
        anims.fillMode  = kCAFillModeForwards;
        anims.animations = [NSArray arrayWithObjects:pathAnim, nil];
        
        [CATransaction setCompletionBlock:^{
            float finalRadius = kScanningCircleRadius;
            
            CGRect finalRect = CGRectMake(CGRectGetMidX(self.overlay.frame) - finalRadius, CGRectGetMidY(self.overlay.frame) - finalRadius
                                          , 2 * finalRadius, 2 * finalRadius);
            

            self.yelloCircle = [CAShapeLayer layer];
            self.yelloCircle.frame = self.overlay.bounds;
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:finalRect];
            self.yelloCircle.path = [path CGPath];
            self.yelloCircle.fillColor = [UIColor clearColor].CGColor;
            self.yelloCircle.lineCap=kCALineCapRound;
            self.yelloCircle.lineDashPattern = kLineDashPattern;
            self.yelloCircle.anchorPoint = (CGPoint){0.5, 0.5};
            UIColor *strokeColor= [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
            self.yelloCircle.strokeColor = strokeColor.CGColor;
            self.yelloCircle.lineWidth = kScanningCircleBorder;
            
            CABasicAnimation *rotateAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotateAnim.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/];
            rotateAnim.duration = kSpinnerCircleSpeed;
            rotateAnim.cumulative = YES;
            rotateAnim.repeatCount = HUGE_VAL;
            [self.yelloCircle addAnimation:rotateAnim forKey:@"rotationAnimation"];
            
            [self.overlay.layer addSublayer:self.yelloCircle];
            
            [self.yelloCircle setNeedsDisplay];
            
            [[PGCameraManager sharedInstance] startScanning];
        }];
        
        [self.scanningCircle addAnimation:anims forKey:nil];
        [CATransaction commit];
        
        [self.view addSubview:self.overlay];
    }
    
    if (self.yelloCircle)
        [self.yelloCircle setNeedsDisplay];
    
    [self.scanningCircle setNeedsDisplay];
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
