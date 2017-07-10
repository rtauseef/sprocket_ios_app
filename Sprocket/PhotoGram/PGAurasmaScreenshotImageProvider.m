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

#import <AurasmaSDK/AurasmaSDK.h>
#import "PGAurasmaScreenshotImageProvider.h"

@interface PGAurasmaScreenshotImageProvider()

@property (strong, nonatomic) AURSocialService *socialService;
@property (strong, nonatomic) AURScreenshotImage *image;
@property (strong, nonatomic) NSURL *shareLink;

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation PGAurasmaScreenshotImageProvider

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
        [self setImage:image];
        [self setSocialService:socialService];
        [self setActivityIndicatorView:indicatorView];
    }
    return self;
}

- (id)item {
    if ([self.activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
        return self.image;
    }
    
    [self getShareLink];
    return self.shareLink;
}

- (void)getShareLink {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    if (!self.shareLink) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
        });
        
        void (^callback)(NSError *, NSURL *) = ^(NSError *error, NSURL *result) {
            if (!error) {
                self.shareLink = result;
            }
            
            dispatch_semaphore_signal(semaphore);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicatorView stopAnimating];
            });
        };
        
        [self.socialService shareLinkForImage:self.image andShouldWatermark:NO withCallback:callback];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end
