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

#import <MobileCoreServices/MobileCoreServices.h>
#import <HPPR.h>
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import "PGCameraRollLandingPageViewController.h"
#import "UIViewController+Trackable.h"
#import "PGPreviewViewController.h"
#import "PGImagePickerLandscapeSupportController.h"
#import "PGAnalyticsManager.h"
#import "PGCameraManager.h"
#import "HPPRCameraRollLoginProvider.h"
#import "HPPRCameraRollPhotoProvider.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Animations.h"
#import "SWRevealViewController.h"
#import "PGSelectAlbumDropDownViewController.h"
#import "PGMediaNavigation.h"

NSString * const kCameraRollUserName = @"CameraRollUserName";
NSString * const kCameraRollUserId = @"CameraRollUserId";

@interface PGCameraRollLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate, PGSelectAlbumDropDownViewControllerDelegate>

@property (strong, nonatomic) void(^accessCompletion)(BOOL granted);
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIImage *selectedPhoto;

@end

@implementation PGCameraRollLandingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Camera Roll Landing Page Screen";
    
    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.containerView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.delegate = self;
    
    [self showPhotoGallery];
}

- (IBAction)signInButtonTapped:(id)sender
{
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self showPhotoGallery];
            [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestOkAction
                                                                  device:kEventAuthRequestPhotosLabel];
        } else {
            [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestDeniedAction
                                                                  device:kEventAuthRequestPhotosLabel];
        }
    }];
}

- (HPPRSelectPhotoProvider *)albumsPhotoProvider {
    return [HPPRCameraRollPhotoProvider sharedInstance];
}

- (void)showPhotoGallery
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;

    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeLocalPhotos];
    [self willSignInToSocialSource:socialSource];

    [[HPPRCameraRollLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [[PGMediaNavigation sharedInstance] showAlbumsDropDownButtonDown:NO];
            [self didSignInToSocialSource:socialSource];

            [self presentPhotoGalleryWithSettings:^(HPPRSelectPhotoCollectionViewController *viewController) {
                [spinner removeFromSuperview];
                viewController.provider = [HPPRCameraRollPhotoProvider sharedInstance];
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didFailSignInToSocialSource:socialSource];
                [spinner removeFromSuperview];
            });
        }
    }];
}

#pragma mark - HPPRSelectPhotoCollectionViewControllerDelegate

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media
{
    [[PGPhotoSelection sharedInstance] selectMedia:media];
    [PGPreviewViewController presentPreviewPhotoFrom:self andSource:source animated:YES];
    
    HPPRCameraRollPhotoProvider *provider = [HPPRCameraRollPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:kCameraRollUserName userId:kCameraRollUserId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didChangeViewMode:(HPPRSelectPhotoCollectionViewMode)viewMode
{
    NSString *mode;
    if (viewMode == HPPRSelectPhotoCollectionViewModeGrid) {
        mode = kPhotoCollectionViewModeGrid;
    } else {
        mode = kPhotoCollectionViewModeList;
    }

    [[PGAnalyticsManager sharedManager] trackPhotoCollectionViewMode:mode];
}

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, PGLandingPageViewControllerCollectionViewBottomInset, 0);
}


@end
