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
#import <MP.h>
#import <MPPrintItemFactory.h>
#import <MPBTPrintManager.h>
#import "HPPRAurasmaImageMedia.h"
#import "PGAurasmaViewController.h"
#import "PGAurasmaTrackingViewDelegate.h"
#import "PGAurasmaScreenshotViewController.h"
#import "PGAurasmaRecordingViewController.h"
#import "PGPhotoSelection.h"
#import "PGPreviewViewController.h"

#import "PGAurasmaGlobalContext.h"

#define MAX_RECODING_DURATION 10.0f

@interface PGAurasmaViewController () <AURTrackingControllerDelegate,
                                        PGAurasmaRecordingViewControllerDelegate,
                                        PGAurasmaScreenshotViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *screenshotButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (strong, nonatomic) AURSocialService *socialService;
@property (strong, nonatomic) AURCachedContentService *cachedContentService;
@property (strong, nonatomic) AURTrackingController *aurasmaTrackingController;
@property (strong, nonatomic) id <PGAurasmaTrackingViewDelegate> closingDelegate;
@property (strong, nonatomic) AURView *trackingView;
@property (strong, nonatomic) NSString *trackingAuraId; // id of the last aura to start tracking
@property (strong, nonatomic) NSTimer *recordingTimer;
@property (nonatomic, assign) AURTrackingState lastTrackingState;

@end

@implementation PGAurasmaViewController

- (void)dealloc {
    [self.aurasmaTrackingController removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PGAurasmaGlobalContext *globalContext = [PGAurasmaGlobalContext instance];
    [globalContext loginAndStartSync];
    AURContext *aurasmaContext = globalContext.context;
    
    /*
     Before creating an AURView, an AURTrackingController must be acquired to back it.
     As the AURTrackingController is responsible for (among other things) taking the camera session,
     there can only be one controller allocated at any one time.
     As long as the controller is retained it will be attempting to track Auras in the camera feed, whether
     an associated AURView is visible or not.
     */
    self.aurasmaTrackingController = [AURTrackingController getTrackingControllerWithContext:aurasmaContext];
    [self.aurasmaTrackingController addDelegate:self];
    
    [self.aurasmaTrackingController addObserver:self
                                 forKeyPath:NSStringFromSelector(@selector(state))
                                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                    context:nil];
    
    [[self aurasmaTrackingController] setDetachingAurasAvailability:YES];
    CGRect frameRect = [UIScreen mainScreen].applicationFrame;
    /* Create a full-frame AURView */
    self.trackingView = [AURView viewWithFrame:frameRect andController:self.aurasmaTrackingController];
    
    /* Turn on the scanning animation */
    [self.trackingView enableScanningAnimation];
    
    [self.view insertSubview:self.trackingView atIndex:0];
    
    self.socialService = [AURSocialService getServiceWithContext:aurasmaContext];
    self.cachedContentService = [AURCachedContentService getServiceWithContext:aurasmaContext];
    self.lastTrackingState = AURTrackingState_Idle;
}


- (IBAction)close:(id)sender {
    [self.aurasmaTrackingController removeDelegate:self];
    [self.closingDelegate finishedTracking:self];
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
    self.screenshotButton.userInteractionEnabled = NO;
    
    [self.trackingView createScreenshotWithCallback:^(NSError *error, AURScreenshotImage *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Screenshot error: %@", error);
                self.screenshotButton.userInteractionEnabled = YES;
            }
            else {
                PGAurasmaScreenshotViewController *aurasmaScreenshotViewController = [[PGAurasmaScreenshotViewController alloc] initWithNibName:@"PGAurasmaScreenshotViewController" bundle:nil];
                aurasmaScreenshotViewController.image = result;
                aurasmaScreenshotViewController.screenshotDelegate = self;
                aurasmaScreenshotViewController.socialService = self.socialService;
                [self presentViewController:aurasmaScreenshotViewController animated:YES completion:nil];
            }
        });
    }];
}

- (IBAction)recordButtonPressed:(id)sender {
    
    self.progressBar.hidden = NO;
    self.progressBar.progress = 0.0f;
    
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(updateRecordingProgress:)
                                                     userInfo:nil
                                                      repeats:YES];
    
    [self observeValueForKeyPath:@"state" ofObject:self.aurasmaTrackingController change:nil context:NULL];
    __weak id weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.screenshotButton.hidden = YES;
        self.recordButton.hidden = YES;
        [self.trackingView startRecordingWithCallback:^(NSError *error, NSURL *fileUrl) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf recordingDidFinishWithFile:(NSURL *)fileUrl andError:(NSError *)error];
            });
        }];
        
    });
    
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}

- (void)updateRecordingProgress:(NSTimer *)timer {
    
    self.screenshotButton.hidden = YES;
    self.recordButton.hidden = YES;
    
    self.stopButton.hidden = NO;
    self.progressBar.progress += 1.0f / MAX_RECODING_DURATION;
    
    if (self.progressBar.progress >= 1.0f) {
        [self.trackingView stopRecording];
    }
    
}
- (IBAction)stopButtonPressed:(id)sender {
    [self.trackingView stopRecording];
    self.stopButton.hidden = YES;
}


- (void)recordingDidFinishWithFile:(NSURL *)fileUrl andError:(NSError *)error {
    [self.recordingTimer invalidate];
    self.recordingTimer = nil;
    self.screenshotButton.highlighted = NO;
    self.progressBar.hidden = YES;
    [self observeValueForKeyPath:@"state" ofObject:self.aurasmaTrackingController change:nil context:NULL];
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
    self.stopButton.hidden = YES;
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
    self.screenshotButton.hidden = recording;
    self.recordButton.hidden = recording;
    [self.trackingView setNeedsDisplay];
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
    self.trackingAuraId = auraId;
    
    NSLog(@"auraStarted: %@\n", auraId);
}

- (void)auraFinished:(NSString *)auraId {
    self.trackingAuraId = nil;
    
    NSLog(@"auraFinished: %@\n", auraId);
}

- (BOOL)handleURL:(NSURL *)url {
    if ([@"sprocketprint" isEqualToString:[url scheme]]) {
        [self.trackingView createScreenshotWithCallback:^(NSError *error, AURScreenshotImage *result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"sprocketprint error: %@", error);
                    return;
                }
                
                HPPRAurasmaImageMedia *imageMedia = [[HPPRAurasmaImageMedia alloc] initWithImage:result andId:self.trackingAuraId];
                [[PGPhotoSelection sharedInstance] selectMedia:imageMedia];
                [PGPreviewViewController presentPreviewPhotoFrom:self andSource:@"Aurasma" animated:YES];
            });
        }];
        return YES;
    }
    return NO;
}


- (void)foundLinkReaderWatermarkPayoff:(id<LRPayoff>)payoff {
    NSLog(@"linkreader, we have a payoff");
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
    BOOL recording = self.recordingTimer != nil;
    [self setLastTrackingState:(AURTrackingState) [stateValue unsignedIntValue]];
    switch ([self lastTrackingState]) {
        case AURTrackingState_Idle:
        case AURTrackingState_Detecting:
            self.screenshotButton.hidden = YES;
            self.recordButton.hidden = YES;
            self.flashButton.hidden = NO;
            self.closeButton.hidden = NO;
            self.stopButton.hidden = YES;
            
            break;
        case AURTrackingState_Tracking:
        case AURTrackingState_Detached:
            [self setupRecordingButtons:recording];
            self.flashButton.hidden = YES;
            self.closeButton.hidden = recording;
            self.stopButton.hidden = YES;
            
            break;
            
        case AURTrackingState_Fullscreen:
            
            [self setupRecordingButtons:recording];
            
            self.stopButton.hidden = YES;
            self.flashButton.hidden = YES;
            self.closeButton.hidden = YES;
            
            break;
    }
}

- (void)cacheAndStartDetachedAura:(NSString *)auraId {
    
    // will not double trigger aura
    if ([self lastTrackingState] != AURTrackingState_Idle &&
        [self lastTrackingState] != AURTrackingState_Detecting) {
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
        
        if ([strongSelfMain aurasmaTrackingController] != nil){
            
            dispatch_async(dispatch_get_main_queue(), ^{      
                
                if ([[strongSelfMain aurasmaTrackingController] ableToDetachAura:auraId]) {
                    [[strongSelfMain aurasmaTrackingController ] startDetachedAura:auraId];
                } else {
                    [strongSelfMain showSimpleError:NSLocalizedString(@"Not able to play Aura, please check Aura set up", @"")];
                }
                
            });
        }
    };
    
    // fetch aura 
    if ([self cachedContentService] != nil) {
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            [[self cachedContentService] cacheAura:auraId withCallback:callback];
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
        [self.aurasmaTrackingController resume];
    }];
}

#pragma mark PGAurasmaScreenshotViewControllerDelegate

- (void)closeScreenshotViewController:(PGAurasmaScreenshotViewController *)controller {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.aurasmaTrackingController resume];
    }];
    self.screenshotButton.userInteractionEnabled = YES;
}

@end
