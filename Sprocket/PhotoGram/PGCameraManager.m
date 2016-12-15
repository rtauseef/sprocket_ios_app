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
#import "PGLandingMainPageViewController.h"
#import "PGAppDelegate.h"
#import "PGAnalyticsManager.h"
#import "UIViewController+trackable.h"
#import <Crashlytics/Crashlytics.h>

NSString * const kSettingSaveCameraPhotos = @"SettingSaveCameraPhotos";

NSString * const kPGCameraManagerCameraClosed = @"PGCameraManagerClosed";
NSString * const kPGCameraManagerPhotoTaken = @"PGCameraManagerPhotoTaken";

@interface PGCameraManager ()

    @property (weak, nonatomic) UIViewController *viewController;
    @property (strong, nonatomic) PGOverlayCameraViewController *cameraOverlay;
    @property (strong, nonatomic) AVCaptureSession *session;
    @property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
    @property (assign, nonatomic) BOOL isCapturingStillImage;

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

- (void)loadPreviewViewControllerWithPhoto:(UIImage *)photo andInfo:(NSDictionary *)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = photo;
    previewViewController.source = [PGPreviewViewController cameraSource];
    
    self.currentSource = previewViewController.source;
    self.currentSelectedPhoto = previewViewController.selectedPhoto;
    
    if (self.isBackgroundCamera) {
        [self.viewController presentViewController:previewViewController animated:NO completion:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerPhotoTaken object:nil];
    }
}

- (void)startCamera {
    [self.session startRunning];
}

- (void)stopCamera {
    [self.session stopRunning];
}

#pragma mark - Custom Camera Methods

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    if (position == AVCaptureDevicePositionUnspecified) {
        self.lastDeviceCameraPosition = AVCaptureDevicePositionBack;
    } else {
        self.lastDeviceCameraPosition = position;
    }
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == self.lastDeviceCameraPosition) return device;
    }
    return nil;
}

- (void)addCameraToView:(UIView *)view presentedViewController:(UIViewController *)viewController
{
    [view layoutIfNeeded];
    
    self.viewController = viewController;
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *device = [self cameraWithPosition:self.lastDeviceCameraPosition];
    [self configFlash:self.isFlashOn forDevice:device];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.session addInput:input];
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    newCaptureVideoPreviewLayer.frame = view.bounds;
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.stillImageOutput];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [view.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [view.layer addSublayer:newCaptureVideoPreviewLayer];
    });
    
    [self.session startRunning];
    self.isBackgroundCamera = YES;
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

- (void)takePicture
{
    if (self.isCapturingStillImage) {
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
        
        if (![weakSelf userPromptedToSavePhotos]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Auto-Save Settings", @"Settings for automatically saving photos")
                                                                           message:NSLocalizedString(@"Do you want to save new camera photos to your device?", @"Asks the user if they want their photos saved")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"Dismisses dialog without taking action")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [weakSelf setSavePhotos:NO];
                                                                 [weakSelf loadPreviewViewControllerWithPhoto:photo andInfo:nil];
                                                                 [[PGAnalyticsManager sharedManager] trackCameraAutoSavePreferenceActivity:@"Off"];
                                                             }];
            [alert addAction:noAction];
            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Dismisses dialog, and chooses to save photos")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [weakSelf setSavePhotos:YES];
                                                                  [weakSelf saveImage:photo completion:nil];
                                                                  [weakSelf loadPreviewViewControllerWithPhoto:photo andInfo:nil];
                                                                  [[PGAnalyticsManager sharedManager] trackCameraAutoSavePreferenceActivity:@"On"];
                                                              }];
            [alert addAction:yesAction];
            
            [weakSelf.viewController presentViewController:alert animated:YES completion:nil];
        } else {
            if ([weakSelf savePhotos]) {
                [weakSelf saveImage:photo completion:nil];
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
        
        AVCaptureDevice *newCamera = nil;
        
        if (self.lastDeviceCameraPosition == AVCaptureDevicePositionBack) {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            [self configFlash:NO forDevice:newCamera];
            [[PGAnalyticsManager sharedManager] trackCameraDirectionActivity:kEventCameraDirectionSelfieLabel];
        } else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
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
                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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

#pragma mark - Auto-Save Photo Setting

- (BOOL)savePhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingSaveCameraPhotos];
}

- (void)setSavePhotos:(BOOL)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:save forKey:kSettingSaveCameraPhotos];
    [defaults synchronize];
}

- (BOOL)userPromptedToSavePhotos
{
    BOOL userPrompted = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kSettingSaveCameraPhotos]) {
        userPrompted = NO;
    }
    return userPrompted;
}

- (void)saveImage:(UIImage *)image completion:(void (^)(BOOL))completion
{
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            NSString *albumTitle = @"sprocket";

            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", albumTitle];
            PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];

            if ([fetchResult firstObject]) {
                PHAssetCollection *sprocketAlbum = [fetchResult firstObject];

                [self saveImage:image toAssetCollection:sprocketAlbum completion:completion];

            } else {
                __block PHObjectPlaceholder *sprocketAlbumPlaceholder;

                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumTitle];
                    sprocketAlbumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;

                } completionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[sprocketAlbumPlaceholder.localIdentifier] options:nil];
                        PHAssetCollection *sprocketAlbum = fetchResult.firstObject;

                        [self saveImage:image toAssetCollection:sprocketAlbum completion:completion];
                    } else {
                        if (completion) {
                            completion(NO);
                        }
                    }
                }];
            }
            
        } else {
            if (completion) {
                completion(NO);
            }
        }
    }];

}

- (void)saveImage:(UIImage *)image toAssetCollection:(PHAssetCollection *)assetCollection completion:(void (^)(BOOL))completion
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];

        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            completion(success);
        }
    }];
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

@end
