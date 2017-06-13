//
//  PGAurasmaScreenshotImageProvider.m
//  Sprocket
//
//  Created by Alex Walter on 12/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import <AurasmaSDK/AurasmaSDK.h>
#import "PGAurasmaScreenshotImageProvider.h"

@implementation PGAurasmaScreenshotImageProvider {
    AURScreenshotImage *_image;
    NSURL *_shareLink;
    AURSocialService *_socialService;
    UIActivityIndicatorView *_activityIndicatorView;
}

+ (PGAurasmaScreenshotImageProvider *)imageProviderWithImage:(AURScreenshotImage *)image
                                         socialService:(AURSocialService *)socialService
                              andActivityIndicatorView:(UIActivityIndicatorView *)indicatorView {
    
    return [[PGAurasmaScreenshotImageProvider alloc] initWithImage:image
                                               socialService:socialService
                                    andActivityIndicatorView:indicatorView];
}

- (instancetype)initWithImage:(AURScreenshotImage *)image
                socialService:(AURSocialService *)socialService
     andActivityIndicatorView:(UIActivityIndicatorView *)indicatorView {
    
    if ((self = [super initWithPlaceholderItem:image])) {
        _image = image;
        _socialService = socialService;
        _activityIndicatorView = indicatorView;
    }
    return self;
}

- (id)item {
    if ([self.activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
        return _image;
    }
    
    [self getShareLink];
    return _shareLink;
}

- (void)getShareLink {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    if (!_shareLink) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _activityIndicatorView.hidden = NO;
            [_activityIndicatorView startAnimating];
        });
        
        void (^callback)(NSError *, NSURL *) = ^(NSError *error, NSURL *result) {
            if (!error) {
                _shareLink = result;
            }
            
            dispatch_semaphore_signal(semaphore);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicatorView stopAnimating];
            });
        };
        
        [_socialService shareLinkForImage:_image andShouldWatermark:NO withCallback:callback];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end
