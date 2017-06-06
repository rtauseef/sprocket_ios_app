//
//  PGPayoffViewLivePhotoViewController.m
//  Sprocket
//
//  Created by Fernando Caprio on 6/6/17.
//  Copyright © 2017 HP. All rights reserved.
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
    [_spinner startAnimating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.photoView) {
        [self play];
    } else {
        [[PHImageManager defaultManager] requestLivePhotoForAsset:self.originalAsset targetSize:self.view.bounds.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            self.livePhoto = livePhoto;
            
            self.photoView = [[PHLivePhotoView alloc]initWithFrame:self.view.bounds];
            self.photoView.contentMode = UIViewContentModeScaleAspectFit;
            self.photoView.livePhoto = self.livePhoto;

            
            self.photoView.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
            
            [self.view.layer addSublayer:self.photoView.layer];
  
            [_spinner stopAnimating];
            
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
