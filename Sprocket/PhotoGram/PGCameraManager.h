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
#import "PGOverlayCameraViewController.h"

extern NSString * const kPGCameraManagerCameraClosed;

@interface PGCameraManager : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (assign, nonatomic) BOOL isCustomCamera;

+ (PGCameraManager *)sharedInstance;

- (void)addCameraToView:(UIView *)view presentedViewController:(UIViewController *)viewController;
- (void)addCameraButtonsOnView:(UIView *)view;

- (void)showCamera:(UIViewController *)viewController animated:(BOOL)animated;
- (void)dismissCameraAnimated:(BOOL)animated;

- (void)takePicture;
- (void)switchCamera;

- (void)stopCamera;

@end
