//
//  PGAurasmaScreenshotViewController.h
//  Sprocket
//
//  Created by Alex Walter on 12/06/2017.
//  Copyright © 2017 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class AURSocialService;
@class AURScreenshotImage;
@class PGAurasmaScreenshotViewController;

@protocol PGAurasmaScreenshotViewControllerDelegate <NSObject>

- (void)closeScreenshotViewController:(PGAurasmaScreenshotViewController *)controller;

@end

@interface PGAurasmaScreenshotViewController : UIViewController

@property (nonatomic, weak, readwrite) id<PGAurasmaScreenshotViewControllerDelegate> screenshotDelegate;
@property (nonatomic, strong, readwrite) AURScreenshotImage *image;
@property (nonatomic, strong, readwrite) AURSocialService *socialService;

@end
