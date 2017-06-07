//
//  AurasmaViewController.m
//  Sprocket
//
//  Created by Alex Walter on 06/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import <AurasmaSDK/AurasmaSDK.h>
#import "PGAurasmaViewController.h"
#import "PGAurasmaTrackingViewDelegate.h"

#import "PGAurasmaGlobalContext.h"

@interface PGAurasmaViewController () <AURTrackingControllerDelegate>

@end

@implementation PGAurasmaViewController {
    AURContext *_aurasmaContext;
    AURTrackingController *_aurasmaTrackingController;
    id <PGAurasmaTrackingViewDelegate> _closingDelegate;
    AURView *_trackingView;
    NSString *_trackingAuraId; // id of the last aura to start tracking
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
    
    CGRect frameRect = [UIScreen mainScreen].applicationFrame;
    /* Create a full-frame AURView */
    _trackingView = [AURView viewWithFrame:frameRect andController:_aurasmaTrackingController];
    
    /* Turn on the scanning animation */
    [_trackingView enableScanningAnimation];
    
    [self.view insertSubview:_trackingView atIndex:0];
    
}

- (void)setClosingDelegate:(id <PGAurasmaTrackingViewDelegate>)closingDelegate {
    _closingDelegate = closingDelegate;
}


- (IBAction)close:(id)sender {
    [_aurasmaTrackingController removeDelegate:self];
    [_closingDelegate finishedTracking:self];
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
    
    
//    [_socialService auraLikesForId:auraId withOptions:nil andCallback:^(NSError *getLikesError, AURLikeInfo *result) {
//        if (getLikesError) {
//            return;
//        }
//        else {
//            if (_aurasmaTrackingController.state != AURTrackingState_Tracking) {
//                //stopped tracking
//                return;
//            }
//            dispatch_async( dispatch_get_main_queue(), ^{
//                _likeButton.selected = result.byUser;
//                _likeButton.userInteractionEnabled = !result.byUser;
//                _likeButton.hidden = NO;
//            });
//        }
//    }];
//    
//    /* Get some more information about the Aura before logging */
//    [_queryService auraWithId:auraId options:nil andCallback:^(NSError *error, AURAura *result) {
//        if (error) {
//            [_logConsole logMessage:[NSString stringWithFormat:@"auraStarted: %@\n", auraId]];
//        }
//        else {
//            [_logConsole logMessage:[NSString stringWithFormat:@"auraStarted: %@ with name: %@\n", result.auraId, result.name]];
//        }
//    }];
}

- (void)auraFinished:(NSString *)auraId {
    _trackingAuraId = nil;
    
//    /* Get some more information about the Aura before logging */
//    [_queryService auraWithId:auraId options:nil andCallback:^(NSError *error, AURAura *result) {
//        if (error) {
//            [_logConsole logMessage:[NSString stringWithFormat:@"auraFinished: %@\n", auraId]];
//        }
//        else {
//            [_logConsole logMessage:[NSString stringWithFormat:@"auraFinished: %@ with name: %@\n", result.auraId, result.name]];
//        }
//    }];
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
    AURTrackingState state = (AURTrackingState) [stateValue unsignedIntValue];
    switch (state) {
        case AURTrackingState_Idle:
        case AURTrackingState_Detecting:
//            _screenshotButton.hidden = YES;
//            _likeButton.hidden = YES;
//            _recordButton.hidden = YES;
            break;
        case AURTrackingState_Tracking:
        case AURTrackingState_Fullscreen:
        case AURTrackingState_Detached:
//            _screenshotButton.hidden = NO;
            // _likeButton waits until state is known
//            _recordButton.hidden = NO;
            break;
    }
}


@end
