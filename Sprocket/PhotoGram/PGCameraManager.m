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

#import <Crashlytics/Crashlytics.h>
#import <HPPRCameraRollMedia.h>

#import "PGAnalyticsManager.h"
#import "PGAppDelegate.h"
#import "PGCameraManager.h"
#import "PGLandingMainPageViewController.h"
#import "PGOverlayCameraViewController.h"
#import "PGPhotoSelection.h"
#import "PGSavePhotos.h"
#import "UIViewController+trackable.h"
#import "PGAppNavigation.h"
#import <Crashlytics/Crashlytics.h>
#import "PGLinkCredentialsManager.h"

#import <AVKit/AVKit.h>
#import <LinkReaderKit/LinkReaderKit.h>
#import "PGPayoffManager.h"

NSString * const kPGCameraManagerCameraClosed = @"PGCameraManagerClosed";
NSString * const kPGCameraManagerPhotoTaken = @"PGCameraManagerPhotoTaken";


@interface PGCameraManager () <LRCaptureDelegate, LRDetectionDelegate>
    @property (weak, nonatomic) UIViewController *viewController;
    @property (strong, nonatomic) PGOverlayCameraViewController *cameraOverlay;
    @property (strong, nonatomic) AVCaptureSession *session;
    @property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
    @property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
    @property (assign, nonatomic) BOOL isCapturingStillImage;
    @property (weak, nonatomic) LRCaptureManager *lrCaptureManager;
    @property (strong, nonatomic) UIView *cameraView;
    @property (strong, nonatomic) AVCaptureVideoPreviewLayer *scanPreviewLayer;
    @property (strong, nonatomic) AVCaptureVideoPreviewLayer *defaultPreviewLayer;
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
    self.isBackgroundCamera = NO;
    self.isFlashOn = NO;
    self.isCapturingStillImage = NO;
    self.isCapturingVideo = NO;
}

#pragma mark - Private Methods

- (CGAffineTransform)cameraFullScreenTransform {
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
    CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
    
    return scale;
}

#pragma mark - Public Methods

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void)addCameraButtonsOnView:(UIView *)view
{
    static NSString *viewAccessibilityIdentifier = @"PGOverlayCameraView";
    
    // Don't keep adding the same overlay view over and over again...
    for (UIView *subview in view.subviews) {
        if ([subview.accessibilityIdentifier isEqualToString:viewAccessibilityIdentifier]) {
            [subview removeFromSuperview];
        }
    }
    
    [view layoutIfNeeded];
    
    self.cameraOverlay = [[PGOverlayCameraViewController alloc] initWithNibName:@"PGOverlayCameraViewController" bundle:nil];
    self.cameraOverlay.pickerReference = nil;
    self.cameraOverlay.view.frame = view.frame;
    self.cameraOverlay.view.accessibilityIdentifier = viewAccessibilityIdentifier;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [view addSubview:self.cameraOverlay.view];
    });
}

- (void)loadPreviewViewControllerWithVideo:(AVURLAsset *)assetURL andImage:(UIImage *) photo andInfo:(NSDictionary *)info {
    HPPRCameraRollMedia *media = [[HPPRCameraRollMedia alloc] init];
    media.image = photo;
    media.assetURL = assetURL;
    
    [[PGPhotoSelection sharedInstance] selectMedia:media];
    
    self.currentSelectedPhoto = photo;
    self.currentMedia = media;
    self.currentSource = [PGPreviewViewController cameraSource];
    
    if (self.isBackgroundCamera) {
        [PGPreviewViewController presentPreviewPhotoFrom:self.viewController andSource:[PGPreviewViewController cameraSource] media:media animated:NO];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerPhotoTaken object:nil];
    }
}

- (void)loadPreviewViewControllerWithPhoto:(UIImage *)photo andInfo:(NSDictionary *)info
{
    HPPRCameraRollMedia *media = [[HPPRCameraRollMedia alloc] init];
    media.image = photo;
    
    [[PGPhotoSelection sharedInstance] selectMedia:media];
    
    self.currentSelectedPhoto = photo;
    self.currentMedia = media;
    self.currentSource = [PGPreviewViewController cameraSource];
    
    if (self.isBackgroundCamera) {
        [PGPreviewViewController presentPreviewPhotoFrom:self.viewController andSource:[PGPreviewViewController cameraSource] media:media animated:NO];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerPhotoTaken object:nil];
    }
}

- (void)startCamera {
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

- (void)stopCamera {
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
}


#pragma mark - Custom Camera Methods

- (NSArray<AVCaptureDevice *> *)availableDevices {
    NSMutableArray<AVCaptureDevice *> *availableDevices = [[NSMutableArray alloc] init];

    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        [availableDevices addObject:device];
    }

    return [availableDevices copy];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    if (position == AVCaptureDevicePositionUnspecified) {
        position = AVCaptureDevicePositionBack;
    }

    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *selectedDevice;

    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            selectedDevice = device;
            break;
        }
    }

    if (selectedDevice) {
        self.lastDeviceCameraPosition = selectedDevice.position;
    } else if (devices.count > 0) {
        // fallback to the first camera if a camera with the specified position is not available (covers the single camera iPod case)
        selectedDevice = [devices firstObject];
        self.lastDeviceCameraPosition = selectedDevice.position;
    } else {
        self.lastDeviceCameraPosition = AVCaptureDevicePositionUnspecified;
    }

    return selectedDevice;
}

- (void)addCameraToView:(UIView *)view presentedViewController:(UIViewController *)viewController
{
    [view layoutIfNeeded];
    
    self.cameraView = view;
    self.viewController = viewController;
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *device = [self cameraWithPosition:self.lastDeviceCameraPosition];
    [self configFlash:self.isFlashOn forDevice:device];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    if (!input || error) {
        PGLogError(@"Error creating capture device input: %@", error.localizedDescription);
    } else {
        [self.session addInput:input];
        
        self.defaultPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.defaultPreviewLayer.frame = view.bounds;
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.session addOutput:self.stillImageOutput];
        
        self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([self.session canAddOutput:self.movieFileOutput]) {
            [self.session addOutput:self.movieFileOutput];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [view.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            [view.layer addSublayer:self.defaultPreviewLayer];
        });
        
        [self.session startRunning];
    }
}

- (void)configFlash:(BOOL)isFlashOn forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash]){
        [device lockForConfiguration:nil];
        if (isFlashOn) {
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}

- (void)startRecording {
    if (self.isCapturingStillImage || self.isCapturingVideo) {
        return;
    }
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
        {
            PGLogError(@"Error creating temporary video file: %@", error.localizedDescription);
            return;
        }
    }
    
    //Start recording
    self.isCapturingVideo = YES;
    [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

- (void)stopRecording {
    [self.movieFileOutput stopRecording];
}

- (void)takePicture
{
    if (self.isCapturingStillImage || self.isCapturingVideo) {
        return;
    }
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    __weak PGCameraManager *weakSelf = self;
    self.isCapturingStillImage = YES;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *photo = [[UIImage alloc] initWithData:imageData];
        
        if (![PGSavePhotos userPromptedToSavePhotos]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Auto-Save Settings", @"Settings for automatically saving photos")
                                                                           message:NSLocalizedString(@"Do you want to save new camera photos to your device?", @"Asks the user if they want their photos saved")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"Dismisses dialog without taking action")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [PGSavePhotos setSavePhotos:NO];
                                                                 [weakSelf loadPreviewViewControllerWithPhoto:photo andInfo:nil];
                                                                 [[PGAnalyticsManager sharedManager] trackCameraAutoSavePreferenceActivity:@"Off"];
                                                             }];
            [alert addAction:noAction];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Dismisses dialog, and chooses to save photos")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [PGSavePhotos setSavePhotos:YES];
                                                                  [PGSavePhotos saveImage:photo completion:nil];
                                                                  [weakSelf loadPreviewViewControllerWithPhoto:photo andInfo:nil];
                                                                  [[PGAnalyticsManager sharedManager] trackCameraAutoSavePreferenceActivity:@"On"];
                                                              }];
            [alert addAction:yesAction];
            
            [weakSelf.viewController presentViewController:alert animated:YES completion:nil];
        } else {
            if ([PGSavePhotos savePhotos]) {
                [PGSavePhotos saveImage:photo completion:nil];
            }
            [weakSelf loadPreviewViewControllerWithPhoto:photo andInfo:nil];
        }
        
        self.isCapturingStillImage = NO;
    }];
}

- (void)switchCamera
{
    if (self.session) {
        [self.session beginConfiguration];
        AVCaptureInput *currentCameraInput = [self.session.inputs objectAtIndex:0];
        
        [self.session removeInput:currentCameraInput];

        AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
        if (self.lastDeviceCameraPosition == AVCaptureDevicePositionBack) {
            position = AVCaptureDevicePositionFront;
        }

        AVCaptureDevice *newCamera = [self cameraWithPosition:position];

        if (newCamera.position == AVCaptureDevicePositionBack) {
            [self configFlash:NO forDevice:newCamera];
            [[PGAnalyticsManager sharedManager] trackCameraDirectionActivity:kEventCameraDirectionSelfieLabel];
        } else {
            [self configFlash:self.isFlashOn forDevice:newCamera];
            [[PGAnalyticsManager sharedManager] trackCameraDirectionActivity:kEventCameraDirectionBackLabel];
        }

        NSError *err = nil;
        
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        
        if (!newVideoInput || err) {
            PGLogError(@"Error creating capture device input: %@", err.localizedDescription);
        } else {
            [self.session addInput:newVideoInput];
        }
        
        [self.session commitConfiguration];
    }
}

- (void)toggleFlash
{
    self.isFlashOn = !self.isFlashOn;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [self configFlash:self.isFlashOn forDevice:device];
}

- (void)checkCameraPermission:(void (^)())success andFailure:(void (^)())failure
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        failure();
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        success();
    } else if (authStatus == AVAuthorizationStatusDenied){
        failure();
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted){
                success();
                [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestOkAction
                                                                      device:kEventAuthRequestCameraLabel];
            } else {
                failure();
                [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestDeniedAction
                                                                      device:kEventAuthRequestCameraLabel];
            }
        }];
    }
}

- (void)showCameraPermissionFailedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera Access Required", @"We must be able to use the camera on the user's phone")
                                                                   message:NSLocalizedString(@"Allow access in your Settings to take and print photos.", @"Body of Camera Access Required dialog")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Button for dismissing dialog")
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alert addAction:cancel];
    
    
    UIAlertAction *settings = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Button for opening the app settings")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         [PGAppNavigation openSettings];
                                                     }];
    [alert addAction:settings];
    
    [[self topMostController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        photo = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];
    }
    
    [self loadPreviewViewControllerWithPhoto:photo andInfo:info];
}

#pragma mark - Metrics
+ (NSString *)trackableScreenName
{
    return @"Camera Screen";
}

+ (void)logMetrics
{
    NSString *screenName = [PGCameraManager trackableScreenName];
    [[PGAnalyticsManager sharedManager] trackScreenViewEvent:screenName];
    [[Crashlytics sharedInstance] setObjectValue:screenName forKey:[UIViewController screenNameKey]];
}

#pragma mark - AVCaptureFileOutput delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    self.isCapturingVideo = NO;
    
    __weak PGCameraManager *weakSelf = self;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:outputFileURL options:nil];
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.requestedTimeToleranceAfter =  kCMTimeZero;
    generator.requestedTimeToleranceBefore =  kCMTimeZero;
    generator.appliesPreferredTrackTransform = YES;
    CGSize maxSize = CGSizeMake(480, 640);
    generator.maximumSize = maxSize;
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        
        if (result != AVAssetImageGeneratorSucceeded) {
            PGLogError(@"couldn't generate thumbnail for video, error:%@", error.localizedDescription);
            return;
        }
        
        UIImage *frameImage = [UIImage imageWithCGImage:im];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([PGSavePhotos savePhotos]) {
                [PGSavePhotos saveVideo:asset completion:nil];
                
                [weakSelf loadPreviewViewControllerWithVideo:asset andImage:frameImage andInfo:nil];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Auto-Save Settings", @"Settings for automatically saving photos")
                                                                               message:NSLocalizedString(@"Do you want to save new camera photos to your device?", @"Asks the user if they want their photos saved")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"Dismisses dialog without taking action")
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [PGSavePhotos setSavePhotos:NO];
                                                                     [weakSelf loadPreviewViewControllerWithVideo:asset andImage:frameImage andInfo:nil];
                                                                     [[PGAnalyticsManager sharedManager] trackCameraAutoSavePreferenceActivity:@"Off"];
                                                                 }];
                [alert addAction:noAction];
                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Dismisses dialog, and chooses to save photos")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      [PGSavePhotos setSavePhotos:YES];
                                                                      [PGSavePhotos saveVideo:asset completion:nil];
                                                                      [weakSelf loadPreviewViewControllerWithVideo:asset andImage:frameImage andInfo:nil];
                                                                      [[PGAnalyticsManager sharedManager] trackCameraAutoSavePreferenceActivity:@"On"];
                                                                  }];
                [alert addAction:yesAction];
            }

        });
    };
    
    NSMutableArray *timeArray = [NSMutableArray array];
    [timeArray addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(0, 600)]];
    
    [generator generateCGImagesAsynchronouslyForTimes:timeArray completionHandler:handler];
}

#pragma mark Link Scanning Methods

- (void) startScanning {
    if (!self.lrCaptureManager) {
        [[LRDetection sharedInstance] setDelegate:self];
        self.lrCaptureManager = [LRCaptureManager sharedManager];
        self.lrCaptureManager.delegate = self;
    }
    
    [self stopCamera];
    //[self.session stopRunning];
    
    if ([[LRManager sharedManager] isAuthorized]) {
        NSError *error;

            if ([self.lrCaptureManager startSession]) {
                NSLog(@"Link scanning is now running ...");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.defaultPreviewLayer removeFromSuperlayer];
                    self.scanPreviewLayer = [self.lrCaptureManager previewLayer];
                    [self.scanPreviewLayer setFrame:self.cameraView.bounds];
                    [self.cameraView.layer addSublayer:self.scanPreviewLayer];
                });
                
                [[LRCaptureManager sharedManager] startScanning: &error];
                if (error) {
                    NSLog(@"An error occurred when scanning was started: %@", error);
                    [self.cameraOverlay stopScanning];
                } else{
                    NSLog(@"Scanning is good...");
                }
            }
    } else {
        NSLog(@"The App is not authorized to use the LinkReaderKit services");
    }

}

- (void) stopScanning {
    [self.lrCaptureManager stopSession];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scanPreviewLayer removeFromSuperlayer];
        
        [self addCameraToView:self.cameraView presentedViewController:self.viewController];
    });
    
    [[LRDetection sharedInstance] setDelegate:nil];
    self.lrCaptureManager.delegate = nil;
    self.lrCaptureManager = nil;
}

-(void) runAuthorization {
    // 1. Pass your credentials to get authorized.
    [[LRManager sharedManager] authorizeWithClientID:[PGLinkCredentialsManager clientId] secret:[PGLinkCredentialsManager clientSecret] success:^{
        
        [self.cameraOverlay enableLinkWatermarking];
    } failure:^(NSError *error) {
        // Authentication or Network Error
    }];
    
}

#pragma mark Link Capture Delegates

- (void)didFindPayoff:(id<LRPayoff>)payoff {
    [self.cameraOverlay stopScanning];
    
    if ([payoff isKindOfClass:[LRWebPayoff class]]) {
        NSString * surl  = [(LRWebPayoff*)payoff url];
        NSURL * url = [NSURL URLWithString:surl];
        [[PGPayoffManager sharedInstance] resolvePayoffFromURL:url complete:^(NSError *error, PGPayoffMetadata *metadata) {
            if( error ) {
                // TODO handle possible payoff resolving errors, show default AR experience (?)
                NSLog(@"error : %@", error);

            } else {
                [self resolvePayoffFromMetadata:metadata completion:^(BOOL success) {
                    if(!success) {

                    }
                }];
            }
        }];
    }
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
                    [self.viewController presentViewController:ctrl animated:YES completion:^{
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

- (void)errorOnPayoffResolving:(NSError *)error {
    
    // Resolving errors mean that there was a problem retrieving the content.
    // For example: the content server is unreachable and/or the Internet
    // connection is offline.
    [self.cameraOverlay stopScanning];
}

- (void)errorOnPayoffParsing:(NSError *)error {
    
    // Parsing errors mean that there was a problem with the content itself.
    // For example: the content was successfully retrieved, but it's somehow
    // defective (may contain typos, invalid character, etc).
    
    [self.cameraOverlay stopScanning];
}


- (void)cameraFailedError:(NSError *)error {
    NSLog(@"There was an error with the camera session");
}

- (void)didChangeFromState:(LRCaptureState)fromState toState:(LRCaptureState)toState {
    switch (toState) {
        case LRCameraNotAvailable:
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

@end
