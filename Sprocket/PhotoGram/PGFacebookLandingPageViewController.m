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
#import <HPPRFacebookLoginProvider.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import <HPPRFacebookPhotoProvider.h>
#import <HPPRFacebookAlbum.h>
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRCacheService.h>
#import "PGFacebookLandingPageViewController.h"
#import "PGAppDelegate.h"
#import "PGAnalyticsManager.h"
#import "SWRevealViewController.h"
#import "PGPreviewViewController.h"
#import "UIView+Animations.h"
#import "UIViewController+Trackable.h"
#import "PGMediaNavigation.h"

NSString * const kFacebookUserNameKey = @"name";
NSString * const kFacebookUserIdKey = @"id";

@interface PGFacebookLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate, HPPRLoginProviderDelegate>

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation PGFacebookLandingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Facebook Landing Page Screen";
    
    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.signInView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckProviderNotification:) name:CHECK_PROVIDER_NOTIFICATION object:nil];
    
    [HPPRFacebookPhotoProvider sharedInstance].loginProvider.delegate = self;
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

    if (socialSource && socialSource.type == PGSocialSourceTypeFacebook) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self showPhotoGallery];
    }
}

#pragma mark - Utils

- (HPPRSelectPhotoProvider *)albumsPhotoProvider {
    return [HPPRFacebookPhotoProvider sharedInstance];
}

- (void)showPhotoGallery
{
    self.spinner = [self.view addSpinner];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    HPPRFacebookPhotoProvider *provider = [HPPRFacebookPhotoProvider sharedInstance];

    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeFacebook];
    [self willSignInToSocialSource:socialSource];

    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        __block NSString *alertText;
        __block NSString *alertTitle;
        
        if (loggedIn) {
            [self didSignInToSocialSource:socialSource];

            [provider userInfoWithRefresh:NO andCompletion:^(NSDictionary *userInfo, NSError *error) {
                
                if (!error) {
                    provider.user = userInfo;

                    [self presentPhotoGalleryWithSettings:^(HPPRSelectPhotoCollectionViewController *viewController) {
                        [self.spinner removeFromSuperview];

                        viewController.provider = provider;
                    }];

                } else {
                    PGLogError(@"Error retrieving user info");
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors
                    
                    [[HPPRFacebookLoginProvider sharedInstance] logoutWithCompletion:^(BOOL loggedOut, NSError *error) {
                        [self didSignOutToSocialSource:socialSource];
                    }];
                    
                    [self.spinner removeFromSuperview];
                    
                    alertTitle = NSLocalizedString(@"Error", nil);
                    alertText = NSLocalizedString(@"Error retrieving user information.", @"Error retrieving the facebook user information");
                    [self showMessage:alertText withTitle:alertTitle];
                    
                    return;
                }
            }];
            
        } else if (error) {
            [self didFailSignInToSocialSource:socialSource];

            [self.spinner removeFromSuperview];
            if (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code) {
                [self showNoConnectionAvailableAlert];
            } else {
                [[HPPRFacebookLoginProvider sharedInstance] logoutWithCompletion:nil];
            }
        } else {
            [self.spinner removeFromSuperview];
            [self didSignOutToSocialSource:socialSource];
        }
    }];
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}


- (void)showLogin
{
    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeFacebook];
    [self willSignInToSocialSource:socialSource];

    [[HPPRFacebookLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn && nil == error) {
            [self didSignInToSocialSource:socialSource];
            [self showPhotoGallery];
        } else if ((nil != error) && (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code)) {
            [self showNoConnectionAvailableAlert];
            [self didFailSignInToSocialSource:socialSource];
        } else {
            [self didFailSignInToSocialSource:socialSource];
            PGLogError(@"FACEBOOK LOGIN ERROR: %@", error);
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
    [PGPreviewViewController presentPreviewPhotoFrom:self andSource:source media:media animated:YES];
    
    HPPRFacebookPhotoProvider *provider = [HPPRFacebookPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:[provider.user objectForKey:kFacebookUserNameKey] userId:[provider.user objectForKey:kFacebookUserIdKey]];
    
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


#pragma mark - PGSelectAlbumDropDownViewControllerDelegate

- (void)selectAlbumDropDownController:(PGSelectAlbumDropDownViewController *)viewController didSelectAlbum:(HPPRAlbum *)album
{
    if ([album objectID] == nil) {
        album = nil;
    }

    [super selectAlbumDropDownController:viewController didSelectAlbum:album];
}


@end
