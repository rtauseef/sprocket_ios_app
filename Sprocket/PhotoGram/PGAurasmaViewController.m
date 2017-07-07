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

#import <AudioToolbox/AudioToolbox.h>
#import <AurasmaSDK/AurasmaSDK.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "PGAurasmaViewController.h"
#import "PGAurasmaTrackingViewDelegate.h"
#import "PGAurasmaScreenshotViewController.h"
#import "PGAurasmaRecordingViewController.h"

#import "PGAurasmaGlobalContext.h"

#define MAX_RECODING_DURATION 10.0f

@interface PGAurasmaViewController () <AURTrackingControllerDelegate,
                                        PGAurasmaRecordingViewControllerDelegate,
                                        PGAurasmaScreenshotViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *flashButton;

@end

@implementation PGAurasmaViewController {
    
    __weak IBOutlet UIButton *_closeButton;
    __weak IBOutlet UIButton *_torchButton;
    __weak IBOutlet UIButton *_screenshotButton;
    __weak IBOutlet UIButton *_stopButton;
    __weak IBOutlet UIButton *_recordButton;
    __weak IBOutlet UIProgressView *_progressBar;

@private
    AURContext *_aurasmaContext;
    AURSocialService *_socialService;
    AURCachedContentService *_cachedContentService;
    
    AURTrackingController *_aurasmaTrackingController;
    id <PGAurasmaTrackingViewDelegate> _closingDelegate;
    AURView *_trackingView;
    NSString *_trackingAuraId; // id of the last aura to start tracking
    NSTimer *_recordingTimer;
    AURTrackingState _lastTrackingState;
}

- (void)dealloc {
    [_aurasmaTrackingController removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PGAurasmaGlobalContext *globalContext = [PGAurasmaGlobalContext instance];
    [globalContext loginAndStartSync];
    _aurasmaContext = globalContext.context;
    
    /*
     Before creating an AURView, an AURTrackingController must be acquired to back it.
     As the AURTrackingController is responsible for (among other things) taking the camera session,
     there can only be one controller allocated at any one time.
     As long as the controller is retained it will be attempting to track Auras in the camera feed, whether
     an associated AURView is visible or not.
     */
    _aurasmaTrackingController = [AURTrackingController getTrackingControllerWithContext:_aurasmaContext];
    [_aurasmaTrackingController addDelegate:self];
    
    [_aurasmaTrackingController addObserver:self
                                 forKeyPath:NSStringFromSelector(@selector(state))
                                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                    context:nil];
    
    [_aurasmaTrackingController setDetachingAurasAvailability:YES];    
    CGRect frameRect = [UIScreen mainScreen].applicationFrame;
    /* Create a full-frame AURView */
    _trackingView = [AURView viewWithFrame:frameRect andController:_aurasmaTrackingController];
    
    /* Turn on the scanning animation */
    [_trackingView enableScanningAnimation];
    
    [self.view insertSubview:_trackingView atIndex:0];
    
    _socialService = [AURSocialService getServiceWithContext:_aurasmaContext];
    _cachedContentService = [AURCachedContentService getServiceWithContext:_aurasmaContext];
    _lastTrackingState = AURTrackingState_Idle;    
}

- (void)setClosingDelegate:(id <PGAurasmaTrackingViewDelegate>)closingDelegate {
    _closingDelegate = closingDelegate;
}


- (IBAction)close:(id)sender {
    [_aurasmaTrackingController removeDelegate:self];
    [_closingDelegate finishedTracking:self];
}


- (IBAction)torchClicked:(id)sender {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device.hasTorch && [device isTorchModeSupported:AVCaptureTorchModeOn]) {
        [device lockForConfiguration:nil];
        device.torchMode = device.torchMode == AVCaptureTorchModeOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [device unlockForConfiguration];
    }
    [self setupButtons];
}

- (IBAction)screenshotButtonPressed:(id)sender {
    _screenshotButton.userInteractionEnabled = NO;
    
    [_trackingView createScreenshotWithCallback:^(NSError *error, AURScreenshotImage *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Screenshot error: %@", error);
                _screenshotButton.userInteractionEnabled = YES;
            }
            else {
                PGAurasmaScreenshotViewController *aurasmaScreenshotViewController = [[PGAurasmaScreenshotViewController alloc] initWithNibName:@"PGAurasmaScreenshotViewController" bundle:nil];
                aurasmaScreenshotViewController.image = result;
                aurasmaScreenshotViewController.screenshotDelegate = self;
                aurasmaScreenshotViewController.socialService = _socialService;
                [self presentViewController:aurasmaScreenshotViewController animated:YES completion:nil];
            }
        });
    }];
}

- (IBAction)recordButtonPressed:(id)sender {
    
    _progressBar.hidden = NO;
    _progressBar.progress = 0.0f;
    
    _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(updateRecordingProgress:)
                                                     userInfo:nil
                                                      repeats:YES];
    
    [self observeValueForKeyPath:@"state" ofObject:_aurasmaTrackingController change:nil context:NULL];
    __weak id weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _screenshotButton.hidden = YES;
        _recordButton.hidden = YES;
        [_trackingView startRecordingWithCallback:^(NSError *error, NSURL *fileUrl) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf recordingDidFinishWithFile:(NSURL *)fileUrl andError:(NSError *)error];
            });
        }];
        
    });
    
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}

- (void)updateRecordingProgress:(NSTimer *)timer {
    
    _screenshotButton.hidden = YES;
    _recordButton.hidden = YES;
    
    _stopButton.hidden = NO;
    _progressBar.progress += 1.0f / MAX_RECODING_DURATION;
    
    if (_progressBar.progress >= 1.0f) {
        [_trackingView stopRecording];
    }
    
}
- (IBAction)stopButtonPressed:(id)sender {
    [_trackingView stopRecording];
    self->_stopButton.hidden = YES;
}


- (void)recordingDidFinishWithFile:(NSURL *)fileUrl andError:(NSError *)error {
    [_recordingTimer invalidate];
    _recordingTimer = nil;
    _screenshotButton.highlighted = NO;
    _progressBar.hidden = YES;
    [self observeValueForKeyPath:@"state" ofObject:_aurasmaTrackingController change:nil context:NULL];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if (!error && !self.presentedViewController) {
        PGAurasmaRecordingViewController *aurasmaRecordingViewController = [[PGAurasmaRecordingViewController alloc] initWithNibName:@"PGAurasmaRecordingViewController" bundle:nil];
        aurasmaRecordingViewController.fileUrl = fileUrl;
        aurasmaRecordingViewController.recordingDelegate = self;
        [self presentViewController:aurasmaRecordingViewController animated:YES completion:nil];
        return;
    }
    
    if (error) {
        NSLog(@"Failed to record Aura %@", error);
        [self showSimpleError:NSLocalizedString(@"Failed to record Aura", @"")];
    }
    
    if (fileUrl) {
        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    }
    self->_stopButton.hidden = YES;
}


- (void)setupButtons
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device.hasTorch) {
        self.flashButton.hidden = YES;
    } else {
        self.flashButton.hidden = NO;
        
        NSString *imageName = device.torchMode == AVCaptureTorchModeOff ? @"cameraFlashOff" : @"cameraFlashOn";
        [self.flashButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

- (void)setupRecordingButtons:(BOOL)recording {
    _screenshotButton.hidden = recording;
    _recordButton.hidden = recording;
    [_trackingView setNeedsDisplay];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark AURTrackingControllerDelegate

/* Just log the events to the on-screen console. */

- (void)auraStarted:(NSString *)auraId {
    _trackingAuraId = auraId;
    
    NSLog(@"auraStarted: %@\n", auraId);
}

- (void)auraFinished:(NSString *)auraId {
    _trackingAuraId = nil;
    
    NSLog(@"auraFinished: %@\n", auraId);
}


// Placeholder code for cross-team collaboration - TODO: replace with MetaR function as follows
// use Link ID to retreive magic frame ID; once fetched from MetaR, invoke cacheAndStartDetachedAura with magic frame ID 
- (void)foundCode:(AVMetadataMachineReadableCodeObject *)code {
    // QR code has an Magic Frame ID embedded in the text 
    NSArray *qritems = [code.stringValue componentsSeparatedByString:@"::"];    
    if ([qritems count] == 2) {
        NSString* magicFrameId = (NSString*)[qritems lastObject];
        [self cacheAndStartDetachedAura:magicFrameId];    
    }
}


#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([object isKindOfClass:[AURTrackingController class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
            NSNumber *stateValue = change[NSKeyValueChangeNewKey];
            [self performSelectorOnMainThread:@selector(respondToStateChange:) withObject:stateValue waitUntilDone:NO];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    
}

#pragma mark Helper functions

- (void)respondToStateChange:(NSNumber *)stateValue {
    
    BOOL recording = _recordingTimer != nil;
    _lastTrackingState = (AURTrackingState) [stateValue unsignedIntValue];
    switch (_lastTrackingState) {
        case AURTrackingState_Idle:
        case AURTrackingState_Detecting:
            _screenshotButton.hidden = YES;
            _recordButton.hidden = YES;
            _torchButton.hidden = NO;
            _closeButton.hidden = NO;
            _stopButton.hidden = YES;
            
            break;
        case AURTrackingState_Tracking:
        case AURTrackingState_Detached:
            [self setupRecordingButtons:recording];
            _torchButton.hidden = YES;
            _closeButton.hidden = recording;
            _stopButton.hidden = YES;
            
            break;
            
        case AURTrackingState_Fullscreen:
            
            [self setupRecordingButtons:recording];
            
            _stopButton.hidden = YES;
            _torchButton.hidden = YES;
            _closeButton.hidden = YES;
            
            break;
    }
}

- (void)cacheAndStartDetachedAura:(NSString *)auraId {
    
    // will not double trigger aura
    if (_lastTrackingState != AURTrackingState_Idle && 
        _lastTrackingState != AURTrackingState_Detecting) {
        return;
    }
    
    __weak PGAurasmaViewController *weakSelf = self;
    
    // set up callback function
    AURCachedContentServiceErrorHandler callback = ^(NSError *error){
        
        PGAurasmaViewController *strongSelfMain = weakSelf;
        if (!strongSelfMain) {
            return;
        }        
                
        if (error) {
            [strongSelfMain showSimpleError:NSLocalizedString(@"Failed to get Aura, please check network connection", @"")];            
            return;
        }
        
        if (strongSelfMain->_aurasmaTrackingController != nil){
            
            dispatch_async(dispatch_get_main_queue(), ^{      
                
                if ([strongSelfMain->_aurasmaTrackingController ableToDetachAura:auraId]) {
                    [strongSelfMain->_aurasmaTrackingController startDetachedAura:auraId];
                } else {
                    [strongSelfMain showSimpleError:NSLocalizedString(@"Not able to play Aura, please check Aura set up", @"")];
                }
                
            });
        }
    };
    
    // fetch aura 
    if (_cachedContentService != nil) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            [_cachedContentService cacheAura:auraId withCallback:callback];
        });
        
    }
}

- (void)showSimpleError:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"")
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") 
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark PGAurasmaRecordingViewControllerDelegate

- (void)closeRecordingViewController:(PGAurasmaRecordingViewController *)controller {
    [self dismissViewControllerAnimated:NO completion:^{
        [_aurasmaTrackingController resume];
    }];
}

#pragma mark PGAurasmaScreenshotViewControllerDelegate

- (void)closeScreenshotViewController:(PGAurasmaScreenshotViewController *)controller {
    [self dismissViewControllerAnimated:NO completion:^{
        [_aurasmaTrackingController resume];
    }];
    _screenshotButton.userInteractionEnabled = YES;
}

@end
