//
//  PGPayoffViewVideoViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/15/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffViewVideoViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PGAppDelegate.h"
#import "AVPlayerViewController+Fullscreen.h"
#import "HPPR.h"

@interface PGPayoffViewVideoViewController ()

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (assign, nonatomic) BOOL readyToPlay;

@end

@implementation PGPayoffViewVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.readyToPlay = NO;
    self.viewTitle = NSLocalizedString(@"Original Video", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PGAppDelegate* appDelegate = (PGAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = NO;
    
    if (!self.readyToPlay) {
        [self.activitySpinner startAnimating];
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    PGAppDelegate* appDelegate = (PGAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    if ([self.player observationInfo]) {
        [self.player removeObserver:self forKeyPath:@"status"];
    }
    
    if ([self.playerViewController.contentOverlayView observationInfo]) {
        [self.playerViewController.contentOverlayView removeObserver:self forKeyPath:@"bounds"];
    }
    
    self.player =nil;
    
    PGAppDelegate* appDelegate = (PGAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) prepareViewController {
    PGAppDelegate* appDelegate = (PGAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = YES;
    
    self.playerViewController = [AVPlayerViewController new];
    self.playerViewController.player = self.player;
    
    self.playerViewController.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.playerViewController.view.frame = self.view.bounds;
    [self.playerViewController.contentOverlayView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.view addSubview: self.playerViewController.view];
}

- (void) setVideoWithAsset: (PHAsset *) asset {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:avasset];
            
            if (item) {
                self.player = [AVPlayer playerWithPlayerItem:item];
                [self prepareViewController];
            } else {
                [self.activitySpinner stopAnimating];
                // handle error
            }
        });
    }];
}

- (void) setVideoWithURL: (NSString *) strUrl {
    NSURL *videoURL = [NSURL URLWithString:strUrl];
    
    self.player = [AVPlayer playerWithURL:videoURL];
    [self prepareViewController];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            self.readyToPlay = YES;
            [self.activitySpinner stopAnimating];
            [self.player play];
            
            PGAppDelegate* appDelegate = (PGAppDelegate*)[UIApplication sharedApplication].delegate;
            appDelegate.restrictRotation = NO;
        } else if (self.player.status == AVPlayerStatusFailed) {
            [self.activitySpinner stopAnimating];
            
            // something went wrong
        }
    } else if (object == self.playerViewController.contentOverlayView && [keyPath isEqualToString:@"bounds"]) {
        CGRect oldBounds = [change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newBounds = [change[NSKeyValueChangeNewKey] CGRectValue];
        BOOL isFullscreen = [UIScreen mainScreen].bounds.size.height == newBounds.size.height && [UIScreen mainScreen].bounds.size.width == newBounds.size.width;
        BOOL wasFullscreen = [UIScreen mainScreen].bounds.size.height == oldBounds.size.height && [UIScreen mainScreen].bounds.size.width == oldBounds.size.width;
        
        if (!isFullscreen && wasFullscreen) {
            NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        }
        
        [self.view setNeedsDisplay];
    }
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            [[self playerViewController] goFullscreen];
            break;
        }
        default:
            break;
    };
}

@end
