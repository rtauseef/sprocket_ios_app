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
#import <Social/Social.h>
#import <AurasmaSDK/AurasmaSDK.h>
#import "PGAurasmaScreenshotTextProvider.h"
#import "PGAurasmaScreenshotImageProvider.h"
#import "PGAurasmaScreenshotViewController.h"

@interface PGAurasmaScreenshotViewController () <UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *popoverViewLocation;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;;

@end

@implementation PGAurasmaScreenshotViewController

#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
    self.imageView.image = self.image;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showActivityViewController];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //The UIActivityViewController sometimes shows it's descendants in landscape even if we are only in portrait so we need to accept all rotations.
    return UIInterfaceOrientationMaskAll;
}

#pragma mark Helpers

- (void)showActivityViewController {
    NSArray *items = @[
                       [PGAurasmaScreenshotTextProvider textProvider],
                       [PGAurasmaScreenshotImageProvider imageProviderWithImage:self.image
                                                            socialService:self.socialService
                                                 andActivityIndicatorView:self.activityIndicatorView]
                       ];
    
    NSArray *customActivities = nil;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                         applicationActivities:customActivities];
    
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
        [activityViewController popoverPresentationController].sourceView = self.view;
    }
    
    activityViewController.excludedActivityTypes = @[
                                                      UIActivityTypeAssignToContact,
                                                      UIActivityTypeCopyToPasteboard,
                                                      UIActivityTypeAirDrop,
                                                      UIActivityTypeAddToReadingList,
                                                      UIActivityTypeMail
                                                      ];
    
    activityViewController.completionWithItemsHandler = ^(NSString *type, BOOL completed, NSArray *items, NSError *error) {
        if (error) {
            NSLog(@"Sharing failed: %@", error);
        }
        
        // delay "fixes" AURASMA-6851
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self.screenshotDelegate closeScreenshotViewController:self];
        });
    };
    
    activityViewController.popoverPresentationController.sourceView = self.popoverViewLocation;
    activityViewController.popoverPresentationController.delegate = self;
    
    [PHPhotoLibrary requestAuthorization:^(__unused PHAuthorizationStatus status) { // fix AURASMA-8234
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:activityViewController animated:YES completion:nil];
        });
    }];
}

#pragma mark UIPopoverPresentationControllerDelegate

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

@end
