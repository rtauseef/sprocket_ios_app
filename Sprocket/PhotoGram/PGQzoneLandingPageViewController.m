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

#import "PGQzoneLandingPageViewController.h"

#import "HPPRSelectPhotoCollectionViewController.h"
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import "HPPRQzoneLoginProvider.h"
#import "HPPRQzonePhotoProvider.h"
#import "PGAnalyticsManager.h"
#import "PGPreviewViewController.h"
#import "UIViewController+Trackable.h"
#import "UIView+Animations.h"
#import "SWRevealViewController.h"
#import "PGSocialSourcesManager.h"

#import <HPPR.h>

@interface PGQzoneLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate, HPPRLoginProviderDelegate>

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation PGQzoneLandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.trackableScreenName = @"Qzone Landing Page Screen";

    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.signInView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckProviderNotification:) name:CHECK_PROVIDER_NOTIFICATION object:nil];
    
    [HPPRQzonePhotoProvider sharedInstance].loginProvider.delegate = self;
    [self showPhotoGallery];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PhotoProvider methods

- (HPPRSelectPhotoProvider *)albumsPhotoProvider {
    return [HPPRQzonePhotoProvider sharedInstance];
}

- (void)showPhotoGallery
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    HPPRQzonePhotoProvider *provider = [HPPRQzonePhotoProvider sharedInstance];

    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeQzone];
    [self willSignInToSocialSource:socialSource];

    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self didSignInToSocialSource:socialSource];

            [self presentPhotoGalleryWithSettings:^(HPPRSelectPhotoCollectionViewController *viewController) {
                [spinner removeFromSuperview];

                viewController.provider = provider;
                viewController.customNoPhotosMessage = NSLocalizedString(@"No Qzone app images found", @"Message displayed when no images from the Qzone app can be found");
            }];

        } else {
            if (error) {
                [self didFailSignInToSocialSource:socialSource];

                if (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code) {
                    [self showNoConnectionAvailableAlert];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self didSignOutToSocialSource:socialSource];
                [spinner removeFromSuperview];
                [self enableSignIn];
            });
        }
    }];
}

- (void)showLogin
{
    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeQzone];
    [self willSignInToSocialSource:socialSource];

    [[HPPRQzoneLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self didSignInToSocialSource:socialSource];
            [self showPhotoGallery];
            [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestOkAction
                                                                  device:kEventAuthRequestPhotosLabel];
        } else {
            [self didFailSignInToSocialSource:socialSource];
            [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestDeniedAction
                                                                  device:kEventAuthRequestPhotosLabel];
        }
    }];
}

- (void)enableSignIn
{
    [UIView animateWithDuration:0.5f animations:^{
        self.signInView.alpha = 1.0f;
    } completion:nil];
}

#pragma mark - Notifications

- (void)handleMenuOpenedNotification:(NSNotification *)notification
{
    self.signInButton.userInteractionEnabled = NO;
    self.termsLabel.userInteractionEnabled = NO;
}

- (void)handleMenuClosedNotification:(NSNotification *)notification
{
    self.signInButton.userInteractionEnabled = YES;
    self.termsLabel.userInteractionEnabled = YES;
}

- (void)handleCheckProviderNotification:(NSNotification *)notification
{
    PGSocialSource *socialSource = [notification.userInfo objectForKey:kSocialNetworkKey];
    
    if (socialSource && socialSource.type == PGSocialSourceTypeQzone) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self showPhotoGallery];
    }
}

#pragma mark - Button actions

- (IBAction)signInButtonTapped:(id)sender
{
    [self showLogin];
}


#pragma mark - HPPRSelectPhotoCollectionViewControllerDelegate

- (void)selectPhotoCollectionViewController:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController didSelectImage:(UIImage *)image source:(NSString *)source media:(HPPRMedia *)media
{
    [[PGPhotoSelection sharedInstance] selectMedia:media];
    [PGPreviewViewController presentPreviewPhotoFrom:self andSource:source media:media animated:YES];
    
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

#pragma mark - HPPRLoginProviderDelegate

- (void)didLogoutWithProvider:(HPPRLoginProvider *)loginProvider
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self showPhotoGallery];
}

@end
