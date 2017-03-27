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
 The error domain string used when camera errors are generated
 
 @since 1.0
 */
extern NSString *const LinkReaderCameraErrorDomain;

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
 Called when an error with the camera session has occurred
 
 @param error Camera error with code
 
 @since 1.0
 */
- (void)cameraFailedError:(NSError *)error;

@end


/**
 LRCaptureManager is the primary interface between the client application and the camera + scanning. The preferred interface for client applications is to use the sharedManager singleton. From there, the camera session may be started so that the video preview may be displayed onscreen. In order to start processing input for data via the scanner, the SDK must first be authorized using [LRManager authorizeWithClientID:secret:success:failure:]

 @since 1.0
 */
@interface LRCaptureManager : NSObject

/**
 The LRCaptureManager delegate received callbacks regarding camera state and errors.

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
 Returns a shared instance of LRCaptureManager. This is the preferred way to interact with the camera capture and scanning.

 @return Shared instance of LRCaptureManager

 @since 1.0
 */
+ (instancetype)sharedManager;

/**
 Begins the camera session and begins live preview.

 @discussion This configures and begins the camera session. If setup appears to be fine, YES is returned and the captureState is set to Running. Any errors that might occur will be reported through the `-cameraFailedError:` delegate method, and are likely due to an AVCaptureSessionRuntimeErrorNotification.

 @return YES If the captureState is successfully set to LRCameraRunning; NO if the session was already running.

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
 
 @discussion The LRManager must have successfully completed authorization before scanning can begin. Should authorization fail, scanning will not start and NO will be returned, along with an error message via the -scannerFailedError: method
 
 @property: error
 
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

/**
 Enumerates the types of camera errors.

 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRCameraError) {

    /**
     An unknown camera error was encountered

     @since 1.0
     */
    LRCaptureErrorUnknown = 0,
    
    /**
     Camera access has been denied by the user (or restricted via parental controls)
     
     @since 1.0
     */
    LRCaptureCameraDenied,
    
    /**
     There was an error configuring the camera or capture session
     
     @since 1.0
     */
    LRCaptureConfigurationError,
    
    /**
     There was an error with a metadata detector
     
     @since 1.0
     */
    LRCaptureErrorDetector,
    
};
