//
//  LRCaptureManager.h
//  Framework Demo
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRManager.h"

@import AVFoundation;

/**
 Enumerates the current state of the camera and frame scanner.
 
 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRCaptureState){
    /**
     The camera is not available for use
     
     @since 1.0
     */
    LRCameraNotAvailable,
    /**
     The camera has stopped, and is not sending frames
     
     @since 1.0
     */
    LRCameraStopped,
    /**
     The camera has started and is sending frames
     
     @since 1.0
     */
    LRCameraRunning,
    /**
     The camera is running, and frames are being processed for data.
     
     @since 1.0
     */
    LRScannerRunning,
};

/**
 The error domain string used when camera errors are generated. See LRCameraError for error types.
 
 @since 1.0
 */
FOUNDATION_EXPORT NSString *const LRCameraErrorDomain;

/**
 Enumerates the types of camera errors found in the LRCameraErrorDomain.
 
 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRCameraError) {
    
    /**
     An unknown camera error was encountered
     
     @since 1.0
     */
    LRCameraErrorUnknown,
    
    /**
     Camera access has been denied by the user (or restricted via parental controls)
     
     @since 1.0
     */
    LRCameraErrorCameraDenied,
    
    /**
     An invalid camera transition ocurred. E.g. from LRCameraStopped to LRCameraScanning by calling startScanning: before startSession
     
     @since 2.1
     */
    LRCameraErrorCameraInvalidTransition,
    
    /**
     There was an error configuring the camera or capture session
     
     @since 1.0
     */
    LRCameraErrorConfigurationError,
    
    /**
     There was an error with a metadata detector
     
     @since 1.0
     */
    LRCameraErrorDetectorError
};

/**
 The LRCaptureDelegate provides a set of methods to help a delegate manage changes to camera/scanner state and error conditions. These are helpful for informing decisions about UI and recovering from problems. For example, the developer may wish to display appropriate UI when state changes from scanning to cameraRunning, or in response to an error.
 
 @since 1.0
 */
@protocol LRCaptureDelegate <NSObject>

/**
 Notifies the delegate when the camera + scanning state has changed
 
 @param fromState The previous state
 @param toState The new state
 
 @since 1.0
 */
- (void)didChangeFromState:(LRCaptureState)fromState toState:(LRCaptureState)toState;

/**
 Called when an error with the camera session has occurred. Error can be of any of the following domains:
 - LRCameraErrorDomain
 - LRAuthorizationErrorDomain
 
 
 @param error Camera error with code
 
 @since 1.0
 */
- (void)cameraFailedError:(NSError *)error;

@end


/**
 
 The primary purpose of LRCaptureManager is to allow the developer user to have finer-grained control over interaction with the LinkReaderSDK. If you wish to use a simple plug-n-play scanning + presentation option, see `EasyReadingViewController`.
 
 LRCaptureManager is the primary interface between the client application and the camera + scanning.
 
 Please refer to the LRManager class for instructions on how to use the `LRManager`/`LRDetection`/LRCaptureManager/`LRPresenter` classes.

 @since 1.0
 */
@interface LRCaptureManager : NSObject

/**
 The LRCaptureManager delegate receives callbacks regarding camera state and errors.

 @since 1.0
 */
@property (nonatomic, weak) id<LRCaptureDelegate> delegate;

/**
 The current state of the camera and data scanner. @see LRCaptureState
 
 @discussion The captureState signifies the current state and capabilities of the camera and data scanning session. When stopped, the camera session is not running (you will not receive live video to the screen). When running, the camera is capturing frames. When scanning, the camera's output frames are actively scanned for data.
 
 @since 1.0
 */
@property (nonatomic, readonly) LRCaptureState captureState;

/**
 This is the AVCaptureVideoPreviewLayer that displays video onscreen. Add it to your preview view's layer.

 @since 1.0
 */
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

/**
 The AVCaptureDevice object used to capture the video frames from the camera.

 @since 1.0
 */
@property (nonatomic, readonly) AVCaptureDevice *device;

/**
 Returns a shared instance of LRCaptureManager.

 @return The LRCaptureManager shared instance

 @since 1.0
 */
+ (instancetype)sharedManager;

/**
 Begins the camera session and begins live preview.

 @discussion This configures and begins the camera session. If setup appears to be fine, YES is returned and the captureState is set to Running. Any errors that might occur will be reported through the `-cameraFailedError:` delegate method, and are likely due to an AVCaptureSessionRuntimeErrorNotification.

 @return YES If the captureState successfully transitioned to LRCameraRunning; NO if the session was already running or an error ocurred.

 @since 1.0
 */
- (BOOL)startSession;

/**
 Stop the camera session. When called, the camera will stop capture and presenting a live preview.
 
 @since 1.0
 */
- (void)stopSession;

/**
 Start actively scanning for content via the camera input. The camera must be running.
 
 @discussion The LRManager must have successfully completed authorization before scanning can begin. If the application has not been authorized, scanning will not start and NO will be returned.
 
 @param error Pointer to an error object that might be populated when an error ocurrs.
 
 @return BOOL YES if scanning started, NO if there was an error.
 
 @since 1.0
 */
- (BOOL)startScanning:(NSError **)error;

/**
 Stop actively scanning for content via the camera input. This does not stop the camera session (preview continues).
 
 @since 1.0
 */
- (void)stopScanning;

@end
