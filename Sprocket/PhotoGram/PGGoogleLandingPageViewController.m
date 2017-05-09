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

#import <HPPR.h>
#import <HPPRGoogleLoginProvider.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import <HPPRGooglePhotoProvider.h>
#import <HPPRGoogleAlbum.h>
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRCacheService.h>
#import "PGGoogleLandingPageViewController.h"
#import "PGAppDelegate.h"
#import "PGAnalyticsManager.h"
#import "SWRevealViewController.h"
#import "PGPreviewViewController.h"
#import "UIView+Animations.h"
#import "UIViewController+Trackable.h"
#import "PGMediaNavigation.h"

static NSString * const kGoogleUserNameKey = @"userName";
static NSString * const kGoogleUserIdKey = @"userID";

@interface PGGoogleLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate, HPPRLoginProviderDelegate>

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation PGGoogleLandingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Google Landing Page Screen";
    
    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.signInView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckProviderNotification:) name:CHECK_PROVIDER_NOTIFICATION object:nil];
    
    [HPPRGooglePhotoProvider sharedInstance].loginProvider.delegate = self;
    [self showPhotoGallery];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    if (socialSource && socialSource.type == PGSocialSourceTypeGoogle) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self showPhotoGallery];
    }
}

#pragma mark - Utils

- (HPPRSelectPhotoProvider *)albumsPhotoProvider {
    return [HPPRGooglePhotoProvider sharedInstance];
}

- (void)showPhotoGallery
{
    self.spinner = [self.view addSpinner];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    HPPRGooglePhotoProvider *provider = [HPPRGooglePhotoProvider sharedInstance];

    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeGoogle];

    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            
            if (!error) {
                [self presentPhotoGalleryWithSettings:^(HPPRSelectPhotoCollectionViewController *viewController) {
                    [self.spinner removeFromSuperview];
                    
                    viewController.provider = provider;
                }];
            }
        } else if (error) {
            [self didFailSignInToSocialSource:socialSource];

            [self.spinner removeFromSuperview];
            if (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code) {
                [self showNoConnectionAvailableAlert];
            } else {
                [[HPPRGoogleLoginProvider sharedInstance] logoutWithCompletion:nil];
            }
        } else {
            [self.spinner removeFromSuperview];
            [self didSignOutToSocialSource:socialSource];
        }
    }];
}

- (void)showLogin
{
    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeGoogle];

    [[HPPRGoogleLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn && nil == error) {
            [self showPhotoGallery];
        } else if ((nil != error) && (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code)) {
            [self showNoConnectionAvailableAlert];
            [self didFailSignInToSocialSource:socialSource];
        } else {
            [self didFailSignInToSocialSource:socialSource];
            PGLogError(@"GOOGLE LOGIN ERROR: %@", error);
        }
    }];
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
    [PGPreviewViewController presentPreviewPhotoFrom:self andSource:source animated:YES];
    
    HPPRGoogleLoginProvider *loginProvider = [HPPRGoogleLoginProvider sharedInstance];
    HPPRGooglePhotoProvider *photoProvider = [HPPRGooglePhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:photoProvider.name userName:[loginProvider.user objectForKey:kGoogleUserNameKey] userId:[loginProvider.user objectForKey:kGoogleUserIdKey]];
    
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
}


#pragma mark - PGSelectAlbumDropDownViewControllerDelegate

- (void)selectAlbumDropDownController:(PGSelectAlbumDropDownViewController *)viewController didSelectAlbum:(HPPRAlbum *)album
{
    if ([album objectID] == nil) {
        album = nil;
    }

    [super selectAlbumDropDownController:viewController didSelectAlbum:album];
}


@end
