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

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "PGAurasmaRecordingViewController.h"

@interface PGAurasmaRecordingViewController () <UIPopoverPresentationControllerDelegate>
@end

@implementation PGAurasmaRecordingViewController {
    __weak IBOutlet UIBarButtonItem *_playButton;
    __weak IBOutlet UIBarButtonItem *_pauseButton;
    __weak IBOutlet UIToolbar *_toolbar;
@private
    AVAsset *_video;
    AVPlayer *_player;
    AVPlayerLayer *_layer;
}

@synthesize recordingDelegate = _recordingDelegate;
@synthesize fileUrl = _fileUrl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _video = [AVAsset assetWithURL:_fileUrl];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:_video];
    _player = [AVPlayer playerWithPlayerItem:item];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    _layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_layer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_player.currentItem];
}

- (void)viewDidLayoutSubviews {
    _layer.frame = CGRectMake(self.view.bounds.origin.x,
                              self.view.bounds.origin.y,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height - _toolbar.frame.size.height);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark buttons

- (IBAction)cancelButtonPressed:(id)sender {
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] removeItemAtURL:_fileUrl error:&error]) {
        NSLog(@"Failed to remove temporary file %@", error);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_player.currentItem];
    
    [self->_recordingDelegate closeRecordingViewController:self];
}

- (IBAction)playButtonPressed:(id)sender {
    [_player play];
    _pauseButton.enabled = YES;
    _playButton.enabled = NO;
}

- (IBAction)pauseButtonPressed:(id)sender {
    [_player pause];
    _pauseButton.enabled = NO;
    _playButton.enabled = YES;
}

- (IBAction)rewindButtonPressed:(id)sender {
    [_player pause];
    [_player seekToTime:kCMTimeZero];
    _pauseButton.enabled = NO;
    _playButton.enabled = YES;
}

- (IBAction)actionButtonPressed:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_fileUrl, @""]
                                                                                         applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[ UIActivityTypeMail, UIActivityTypeCopyToPasteboard ];
    
    activityViewController.completionWithItemsHandler = ^(NSString *type, BOOL completed, NSArray *items, NSError *error) {
        if (error) {
            NSLog(@"Sharing failed: %@", error);
        }
        
        if (!completed) {
            return;
        }
        
        [self performSelectorOnMainThread:@selector(cancelButtonPressed:) withObject:nil waitUntilDone:NO];
        
    };
    
    activityViewController.popoverPresentationController.sourceView = _toolbar;
    activityViewController.popoverPresentationController.delegate = self;
    
    [PHPhotoLibrary requestAuthorization:^(__unused PHAuthorizationStatus status) { // fix AURASMA-8234
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityViewController animated:YES completion:nil];
        });
    }];
}

#pragma mark notifications

- (void)playerItemDidPlayToEnd:(__unused NSNotification *)notif {
    _pauseButton.enabled = NO;
    _playButton.enabled = NO;
}

#pragma mark UIPopoverPresentationControllerDelegate

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

@end
