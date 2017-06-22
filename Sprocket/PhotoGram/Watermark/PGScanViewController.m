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

#import "PGScanViewController.h"
#import "PGLinkCredentialsManager.h"
#import "PGPayoffManager.h"
#import <LinkReaderKit/LinkReaderKit.h>
#import <AVKit/AVKit.h>


static const int kAuthNetworkErrorAlert = 700;
static const int kAuthErrorAlert = 701;
static const int kScanningNetworkErrorAlert = 702;
static const int kPayoffDetailsAlert = 800;
static const int kPayoffDoneAlert = 801;
static const int kPayoffErrorAlert = 802;

@interface PGScanViewController () <LRCaptureDelegate, LRDetectionDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *scanningTarget;
@property (weak, nonatomic) LRCaptureManager *lrCaptureManager;
@property (weak, nonatomic) IBOutlet UIView *cameraContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation PGScanViewController

+ (instancetype) new {
    return [[PGScanViewController alloc] initWithNibName:@"PGScanViewController" bundle:nil];
}



-(void) runImageAnimation {
    [self runSpinAnimationOnView:self.scanningTarget duration:1.0 rotations:-1.0 repeat:HUGE_VALF];
}

-(void) onResume {
    [self runImageAnimation];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void) viewWillDisappear:(BOOL)animated {
    [self.lrCaptureManager stopSession];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (IBAction)closeButtonTouchUpInside:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) runAuthorization {
    // 1. Pass your credentials to get authorized.
    [[LRManager sharedManager] authorizeWithClientID:[PGLinkCredentialsManager clientId] secret:[PGLinkCredentialsManager clientSecret] success:^{
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        
        
//        self.cameraContainer.hidden = false;
        
        // ... and start scanning.
        [self startScanning];
        
        self.scanningTarget.hidden = NO;
        [self runImageAnimation];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(onResume)
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    } failure:^(NSError *error) {
        // Authentication or Network Error
        [self displayAuthErrorToUser:error];
    }];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    // hack to prevent AVPlayerViewController from adding status bar
}

- (void)viewDidAppear:(BOOL)animated {
    [self setDelegates];
    // Add the video layer...
    if ([self.lrCaptureManager startSession]) {
        NSLog(@"Video capture setup... success.");
        self.previewLayer = [self.lrCaptureManager previewLayer];
        [self.previewLayer setFrame:self.view.bounds];
        [self.cameraContainer.layer addSublayer:self.previewLayer];
    }

    
    [self runAuthorization];
}

- (void)setDelegates {
    [[LRDetection sharedInstance] setDelegate:self];
    self.lrCaptureManager = [LRCaptureManager sharedManager];
    self.lrCaptureManager.delegate = self;
}

- (void)unsetDelegates {
    [[LRDetection sharedInstance] setDelegate:nil];
    self.lrCaptureManager.delegate = nil;
}


-(void)readerError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSString *title = [error userInfo][@"title"];
    NSString *message = [error userInfo][NSLocalizedDescriptionKey];
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.scanningTarget.hidden = YES;
    [self.activityIndicator startAnimating];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kAuthNetworkErrorAlert) {
        if (buttonIndex == 1) {
            // When the user clicks on Retry...
            [self.activityIndicator startAnimating];
            
            [self runAuthorization];
        
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }else if(alertView.tag == kAuthErrorAlert){
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else if(alertView.tag == kScanningNetworkErrorAlert ||
             alertView.tag == kPayoffDoneAlert ||
             alertView.tag == kPayoffErrorAlert
             ){
        [self startScanning];
    } else if(alertView.tag == kPayoffDetailsAlert){
        
    }
}

#pragma mark - LRDetectionDelegate Methods
//a trigger has been detected
- (void)didFindTrigger:(LRTriggerType)triggerType {
    switch (triggerType) {
        case LRWatermark:
//            NSLog(@"watermark");
            break;
            
        case LRQRCode:
//            NSLog(@"qrcode");
            break;
        default: break;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) resolvePayoffFromMetadata:(PGPayoffMetadata *) meta completion:(void(^)(BOOL success)) handler {
    if( meta.offline ) {
        if( meta.type == kPGPayoffVideo ) {
            PHAsset * asset = [meta fetchPHAsset];
            if( asset ) {

                PHVideoRequestOptions * opt = [PHVideoRequestOptions new];

                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:opt resultHandler:^(AVAsset *vasset, AVAudioMix *audioMix, NSDictionary *info) {
                    AVPlayer * player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:vasset]];
                    AVPlayerViewController * ctrl = [AVPlayerViewController new];
                    ctrl.player = player;

                    [player play];
                    [self presentViewController:ctrl animated:YES completion:^{
                        handler(YES);
                    }];
                }];


            } else {
                handler(NO);
            }


        } else {
            handler(NO);
        }
    } else if(meta.type == kPGPayoffURL && meta.URL) {
        [[UIApplication sharedApplication] openURL:meta.URL options:@{ UIApplicationOpenURLOptionUniversalLinksOnly : @(NO)} completionHandler:^(BOOL success) {
            handler(success);
        }];
    } else {
        handler(NO);
    }
    
}

//a payoff linked to a read trigger has been retrieved
- (void)didFindPayoff:(id<LRPayoff>)payoff {
    //[self presentPayoffData:payoff];
    

    if ([payoff isKindOfClass:[LRWebPayoff class]]) {
        NSString * surl  = [(LRWebPayoff*)payoff url];
        NSURL * url = [NSURL URLWithString:surl];
        [[PGPayoffManager sharedInstance] resolvePayoffFromURL:url complete:^(NSError *error, PGPayoffMetadata *metadata) {
            if( error ) {
                // TODO handle possible payoff resolving errors, show default AR experience (?)
                NSLog(@"error : %@", error);
                [self startScanning];
            } else {
               [self resolvePayoffFromMetadata:metadata completion:^(BOOL success) {
                   if(!success) {
                       [self startScanning];
                   }
               }];
            }
        }];

        
        
    } else {
        [self startScanning];
    }
    

    
}

// 4. If something goes wrong, we'll tell you.
- (void)errorOnPayoffResolving:(NSError *)error {
    
    // Resolving errors mean that there was a problem retrieving the content.
    // For example: the content server is unreachable and/or the Internet
    // connection is offline.
    [self displayLRDetectionError: error tag:kScanningNetworkErrorAlert];
}

- (void)errorOnPayoffParsing:(NSError *)error {
    
    // Parsing errors mean that there was a problem with the content itself.
    // For example: the content was successfully retrieved, but it's somehow
    // defective (may contain typos, invalid character, etc).
    [self displayLRDetectionError: error tag:kPayoffErrorAlert];
}

- (void)displayLRDetectionError:(NSError *)error tag:(int) tag{
    
    NSString *title = @"LR Detection Error";
    NSString *message = error.localizedDescription;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
    alertView.tag = tag;
    [alertView show];
}


- (void)cameraFailedError:(NSError *)error {
    [self readerError:error];
    NSLog(@"There was an error with the camera session");
}

- (void)didChangeFromState:(LRCaptureState)fromState toState:(LRCaptureState)toState {
    switch (toState) {
        case LRCameraNotAvailable:
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error with the capture session" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            break;
        case LRCameraStopped:
            NSLog(@"Camera stopped");
            break;
        case LRCameraRunning:
            NSLog(@"Camera is running");
            break;
        case LRScannerRunning:
            NSLog(@"Scanner is running");
            break;
        default:
            break;
    }
}

#pragma mark - Helper Methods

- (void)startScanning {
    if ([[LRManager sharedManager] isAuthorized]) {
        NSError *error;
        [[LRCaptureManager sharedManager] startScanning: &error];
        if (error) {
            NSLog(@"An error occurred when scanning was started: %@", error);
            [self readerError:error];
        }else{
            [self initVideoPreview];
        }
    } else {
        NSLog(@"The App is not authorized to use the LinkReaderKit services");
    }
}


- (void)displayAuthErrorToUser:(NSError *)error{
    NSString *message;
    NSString *title;
    
    if ([error code] == LRAuthorizationErrorNetworkError) {
        message = [NSString stringWithFormat:@"There is a problem connecting with the server. error: %@",error.localizedDescription ];
        title = @"Network Error";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Retry", nil];
        alertView.tag = kAuthNetworkErrorAlert;
        [alertView show];
        [self.activityIndicator stopAnimating];
        
    } else {
        if ([error code] == LRAuthorizationErrorApiKeyInvalid) {
            message = [NSString stringWithFormat:@"There was an authentication error: %@",error.localizedDescription ];
            title = @"Auth Error";
            
        } else {
            message = [NSString stringWithFormat:@"An error occurred. error: %@",error.localizedDescription ];
            title = @"Error";
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = kAuthErrorAlert;
        [alertView show];
        [self.activityIndicator stopAnimating];
    }
}




-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self initVideoPreview];
    
    self.previewLayer.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void) initVideoPreview{
    if ([self.previewLayer.connection isVideoOrientationSupported]) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        switch (orientation) {
            case UIDeviceOrientationPortrait:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIDeviceOrientationLandscapeLeft:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
