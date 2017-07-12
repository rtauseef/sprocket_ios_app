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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) AVAsset *video;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *layer;

@end

@implementation PGAurasmaRecordingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.video = [AVAsset assetWithURL:self.fileUrl];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.video];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:self.layer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.player.currentItem];
}

- (void)viewDidLayoutSubviews {
    self.layer.frame = CGRectMake(self.view.bounds.origin.x,
                              self.view.bounds.origin.y,
                              self.view.bounds.size.width,
                              self.view.bounds.size.height - self.toolbar.frame.size.height);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark buttons

- (IBAction)cancelButtonPressed:(id)sender {
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] removeItemAtURL:self.fileUrl error:&error]) {
        NSLog(@"Failed to remove temporary file %@", error);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.player.currentItem];
    
    [self.recordingDelegate closeRecordingViewController:self];
}

- (IBAction)playButtonPressed:(id)sender {
    [self.player play];
    self.pauseButton.enabled = YES;
    self.playButton.enabled = NO;
}

- (IBAction)pauseButtonPressed:(id)sender {
    [self.player pause];
    self.pauseButton.enabled = NO;
    self.playButton.enabled = YES;
}

- (IBAction)rewindButtonPressed:(id)sender {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    self.pauseButton.enabled = NO;
    self.playButton.enabled = YES;
}

- (IBAction)actionButtonPressed:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.fileUrl, @""]
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
    
    activityViewController.popoverPresentationController.sourceView = self.toolbar;
    activityViewController.popoverPresentationController.delegate = self;
    
    [PHPhotoLibrary requestAuthorization:^(__unused PHAuthorizationStatus status) { // fix AURASMA-8234
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityViewController animated:YES completion:nil];
        });
    }];
}

#pragma mark notifications

- (void)playerItemDidPlayToEnd:(__unused NSNotification *)notif {
    self.pauseButton.enabled = NO;
    self.playButton.enabled = NO;
}

#pragma mark UIPopoverPresentationControllerDelegate

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

@end
