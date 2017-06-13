//
//  PGAurasmaScreenshotImageProvider.h
//  Sprocket
//
//  Created by Alex Walter on 12/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class AURScreenshotImage;
@class AURSocialService;

@interface PGAurasmaScreenshotImageProvider : UIActivityItemProvider

+ (PGAurasmaScreenshotImageProvider *)imageProviderWithImage:(AURScreenshotImage *)image
                                         socialService:(AURSocialService *)socialService
                              andActivityIndicatorView:(UIActivityIndicatorView *)indicatorView;

@end
