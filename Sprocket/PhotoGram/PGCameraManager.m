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
#import "PGLandingMainPageViewController.h"
#import "PGAppDelegate.h"

NSString * const kPGCameraManagerCameraClosed = @"PGCameraManagerClosed";

@interface PGCameraManager ()

    @property (weak, nonatomic) UIViewController *viewController;
    @property (strong, nonatomic) PGOverlayCameraViewController *cameraOverlay;
    @property (strong, nonatomic) UIImagePickerController *picker;
    @property (strong, nonatomic) AVCaptureSession *session;
    @property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
    @property (assign, nonatomic) AVCaptureDevicePosition lastDeviceCameraPosition;

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
    self.isCustomCamera = NO;
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    self.picker.showsCameraControls = NO;
    self.picker.extendedLayoutIncludesOpaqueBars = NO;
    self.picker.cameraViewTransform = [self cameraFullScreenTransform];
    self.picker.delegate = self;
    
    self.cameraOverlay = [[PGOverlayCameraViewController alloc] initWithNibName:@"PGOverlayCameraViewController" bundle:nil];
    self.cameraOverlay.pickerReference = self.picker;
    self.cameraOverlay.view.frame = self.picker.cameraOverlayView.frame;
    
    self.picker.cameraOverlayView = self.cameraOverlay.view;
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

- (void)showCamera:(UIViewController *)viewController animated:(BOOL)animated
{
    self.isCustomCamera = NO;
    self.cameraOverlay.pickerReference = self.picker;
    
    if (self.lastDeviceCameraPosition == AVCaptureDevicePositionBack) {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    
    self.viewController = viewController;
    [[self topMostController] presentViewController:self.picker animated:animated completion:nil];
}

- (void)addCameraButtonsOnView:(UIView *)view
{
    self.cameraOverlay.pickerReference = nil;
    self.cameraOverlay.view.frame = view.frame;
    
    [view addSubview:self.cameraOverlay.view];
}

- (void)dismissCameraAnimated:(BOOL)animated
{
    [self.picker dismissViewControllerAnimated:animated completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPGCameraManagerCameraClosed object:nil];
}

- (void)loadPreviewViewControllerWithPhoto:(UIImage *)photo andInfo:(NSDictionary *)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = photo;
    previewViewController.media = [[HPPRMedia alloc] initWithAttributes:info];
    previewViewController.source = @"CameraRoll";
    
    if (self.isCustomCamera) {
        [self.viewController presentViewController:previewViewController animated:NO completion:nil];
    } else {
        [self.picker dismissViewControllerAnimated:NO completion:^{
            [[self topMostController] presentViewController:previewViewController animated:NO completion:nil];
        }];
    }
}

- (void)stopCamera {
    [self.session stopRunning];
}

#pragma mark - Custom Camera Methods

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    if (position == AVCaptureDevicePositionUnspecified) {
        self.lastDeviceCameraPosition = AVCaptureDevicePositionFront;
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
    self.viewController = viewController;
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    AVCaptureDevice *device = [self cameraWithPosition:self.lastDeviceCameraPosition];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.session addInput:input];
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    newCaptureVideoPreviewLayer.frame = view.bounds;
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.stillImageOutput];
    
    [view.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [view.layer addSublayer:newCaptureVideoPreviewLayer];
    
    [self.session startRunning];
    self.isCustomCamera = YES;
}

- (void)takePicture
{
    if (self.isCustomCamera) {
        [self captureNow];
    } else {
        [self.picker takePicture];
    }
}

- (void)switchCamera
{
    if (self.isCustomCamera) {
        if (self.session) {
            [self.session beginConfiguration];
            AVCaptureInput *currentCameraInput = [self.session.inputs objectAtIndex:0];
            
            [self.session removeInput:currentCameraInput];
            
            AVCaptureDevice *newCamera = nil;
            
            if (self.lastDeviceCameraPosition == AVCaptureDevicePositionBack) {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            } else {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            
            NSError *err = nil;
            AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
            
            if (!newVideoInput || err) {
                NSLog(@"Error creating capture device input: %@", err.localizedDescription);
            } else {
                [self.session addInput:newVideoInput];
            }
            
            [self.session commitConfiguration];
        }
    } else {
        if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            self.lastDeviceCameraPosition = AVCaptureDevicePositionBack;
        } else {
            self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            self.lastDeviceCameraPosition = AVCaptureDevicePositionFront;
        }
    }
}

- (void)captureNow
{
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
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *photo = [[UIImage alloc] initWithData:imageData];
        photo = [UIImage imageWithCGImage:photo.CGImage scale:photo.scale orientation:UIImageOrientationLeftMirrored];

        [weakSelf loadPreviewViewControllerWithPhoto:photo andInfo:nil];
    }];
}

- (void)checkCameraPermission:(void (^)())success andFailure:(void (^)())failure
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        success();
    } else if (authStatus == AVAuthorizationStatusDenied){
        failure();
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted){
                success();
            } else {
                failure();
            }
        }];
    }
}

- (void)showCameraPermissionFailedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                  message:@"Sprocket does not have access to your camera. To enable access go to iOS Settings > sprocket"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    
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

@end
