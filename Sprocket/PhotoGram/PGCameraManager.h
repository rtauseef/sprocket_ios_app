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

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "PGPreviewViewController.h"

extern NSString * const kPGCameraManagerCameraClosed;
extern NSString * const kPGCameraManagerPhotoTaken;

@interface PGCameraManager : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureFileOutputRecordingDelegate>

typedef NS_ENUM(NSInteger, ShutterTimerDelayState) {
    ShutterTimerDelayStateNone         = 0,
    ShutterTimerDelayStateThree        = 3,
    ShutterTimerDelayStateTen          = 10
};

@property (assign, nonatomic) BOOL isBackgroundCamera;
@property (strong, nonatomic) UIImage *currentSelectedPhoto;
@property (strong, nonatomic) NSString *currentSource;
@property (strong, nonatomic) HPPRMedia *currentMedia;
@property (assign, nonatomic) BOOL isFlashOn;
@property (assign, nonatomic) ShutterTimerDelayState shutterTimerDelayState;
@property (assign, nonatomic) AVCaptureDevicePosition lastDeviceCameraPosition;
@property (assign, nonatomic) BOOL isCapturingVideo;

+ (PGCameraManager *)sharedInstance;
- (void)loadPreviewViewControllerWithVideo:(AVURLAsset *)assetURL andImage:(UIImage *) photo andOriginalAsset: (PHAsset *) originalAsset andInfo:(NSDictionary *)info;
- (NSArray<AVCaptureDevice *> *)availableDevices;

- (void)addCameraToView:(UIView *)view presentedViewController:(UIViewController *)viewController;
- (void)addCameraButtonsOnView:(UIView *)view;

- (void)takePicture;
- (void)startRecording;
- (void)stopRecording;
- (void)switchCamera;
- (void)toggleFlash;
- (void)toggleTimer;

- (void)startCamera;
- (void)stopCamera;

- (void)checkCameraPermission:(void (^)())success andFailure:(void (^)())failure;
- (void)showCameraPermissionFailedAlert;

+ (void)logMetrics;

- (void)startScanning;
- (void)stopScanning;
- (void)runAuthorization:(void (^)(BOOL success))complete;

@end
