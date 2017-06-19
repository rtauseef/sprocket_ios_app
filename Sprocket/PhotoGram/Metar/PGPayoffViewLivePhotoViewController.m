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

#import "PGPayoffViewLivePhotoViewController.h"
#import <PhotosUI/PhotosUI.h>
#import <UIKit/UIKit.h>

@interface PGPayoffViewLivePhotoViewController ()

@property (strong,nonatomic) PHAsset* originalAsset;
@property (strong,nonatomic) PHLivePhoto* livePhoto;
@property (strong,nonatomic) PHLivePhotoView* photoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation PGPayoffViewLivePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.viewTitle = NSLocalizedString(@"Live Photo", nil);
    self.photoView = [[PHLivePhotoView alloc]init];
    self.photoView.hidden = YES;
    [self.view addSubview:self.photoView];

    [_spinner startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.photoView.livePhoto) {
        [self play];
    } else {
        [[PHImageManager defaultManager] requestLivePhotoForAsset:self.originalAsset targetSize:self.view.bounds.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            self.livePhoto = livePhoto;
            
            self.photoView.contentMode = UIViewContentModeScaleAspectFit;
            self.photoView.livePhoto = self.livePhoto;
            self.photoView.frame = self.view.bounds;
            self.photoView.center = self.view.center;
            
            [_spinner stopAnimating];
            self.photoView.hidden = NO;
            
            if (self.isViewLoaded && self.view.window) {
                [self play];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setLivePhotoAsset: (PHAsset *) asset {
    
    self.originalAsset = asset;
}

- (void) play {
    [self.photoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
}

@end
