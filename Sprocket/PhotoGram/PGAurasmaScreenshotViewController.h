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
