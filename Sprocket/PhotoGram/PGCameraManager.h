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
#import "PGOverlayCameraViewController.h"

extern NSString * const kPGCameraManagerCameraClosed;
extern NSString * const kPGCameraManagerPhotoTaken;

@interface PGCameraManager : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (assign, nonatomic) BOOL isBackgroundCamera;
@property (strong, nonatomic) UIImage *currentSelectedPhoto;
@property (strong, nonatomic) NSString *currentSource;
@property (strong, nonatomic) HPPRMedia *currentMedia;
@property (assign, nonatomic) BOOL isFlashOn;
@property (assign, nonatomic) AVCaptureDevicePosition lastDeviceCameraPosition;

+ (PGCameraManager *)sharedInstance;

- (void)addCameraToView:(UIView *)view presentedViewController:(UIViewController *)viewController;
- (void)addCameraButtonsOnView:(UIView *)view;

- (void)takePicture;
- (void)switchCamera;
- (void)toggleFlash;

- (void)startCamera;
- (void)stopCamera;

- (void)checkCameraPermission:(void (^)())success andFailure:(void (^)())failure;
- (void)showCameraPermissionFailedAlert;

- (void)saveImage:(UIImage *)image completion:(void (^)(BOOL success))completion;

+ (void)logMetrics;

@end
