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

#import "HPPRCameraCollectionViewCell.h"

@interface HPPRCameraCollectionViewCell()

@property (unsafe_unretained, nonatomic) IBOutlet UIView *cameraView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *disabledOverlayView;
@property (strong, nonatomic) AVCaptureSession *session;

@end

@implementation HPPRCameraCollectionViewCell


- (void)addCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    if (self.session || devices.count == 0) {
        [self configureSessionPreset];
        return;
    }

    self.session = [[AVCaptureSession alloc] init];
    [self configureSessionPreset];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

    if (!input || error) {
        NSLog(@"Error creating capture device input: %@", error.localizedDescription);
    } else {
        [self.session addInput:input];
        
        CGRect bounds = self.layer.bounds;
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        newCaptureVideoPreviewLayer.bounds = bounds;
        newCaptureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

        [self.cameraView.layer addSublayer:newCaptureVideoPreviewLayer];
    }
    
    [self startCamera];
}

- (void)configureSessionPreset
{
    if (self.layer.bounds.size.width < 200) {
        self.session.sessionPreset = AVCaptureSessionPresetLow;
    } else {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
}

- (void)resetCamera
{
    [self.cameraView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.session stopRunning];
    self.session = nil;
}

- (void)startCamera
{
    [self.session startRunning];
    self.disabledOverlayView.hidden = YES;
}

- (void)stopCamera
{
    [self.session stopRunning];
}

- (void)disableCamera {
    [self stopCamera];
    self.disabledOverlayView.hidden = NO;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) return device;
    }
    return nil;
}

- (void)changeCameraPosition:(AVCaptureDevicePosition)position
{
    if (self.session && position) {
        AVCaptureDeviceInput *currentDevice = (AVCaptureDeviceInput *)self.session.inputs[0];
        if (currentDevice.device.position == position) {
            return;
        }
        
        [self.session beginConfiguration];
        [self.session removeInput:currentDevice];
        
        AVCaptureDevice *newCamera = [self cameraWithPosition:position];
        
        NSError *err = nil;
        
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        
        if (!newVideoInput || err) {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        } else {
            [self.session addInput:newVideoInput];
        }
        
        [self.session commitConfiguration];
    }
}

@end
