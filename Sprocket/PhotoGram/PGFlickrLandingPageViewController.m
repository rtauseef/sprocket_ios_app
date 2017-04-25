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
#import <HPPRFlickrPhotoProvider.h>
#import <HPPRFlickrLoginProvider.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRCacheService.h>
#import <HPPRFlickrAlbum.h>
#import "PGFlickrLandingPageViewController.h"
#import "PGAppDelegate.h"
#import "PGAnalyticsManager.h"
#import "PGPreviewViewController.h"
#import "SWRevealViewController.h"
#import "UIView+Animations.h"
#import "UIViewController+Trackable.h"
#import "PGSocialSourcesManager.h"

NSString * const kFlickrUserNameKey = @"userName";
NSString * const kFlickrUserIdKey = @"userID";

@interface PGFlickrLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) NSDictionary *user;


@end

@implementation PGFlickrLandingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Flickr Landing Page Screen";
    
    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.signInView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckProviderNotification:) name:CHECK_PROVIDER_NOTIFICATION object:nil];
    
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

    if (socialSource && socialSource.type == PGSocialSourceTypeFlickr) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showPhotoGallery];
        });
    }
}


#pragma mark - Utils

- (HPPRSelectPhotoProvider *)albumsPhotoProvider {
    return [HPPRFlickrPhotoProvider sharedInstance];
}

- (void)showPhotoGallery {
    [self showPhotoGalleryNotifyDelegate:YES];
}

- (void)showPhotoGalleryNotifyDelegate:(BOOL)notifyDelegate
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;

    self.signInView.alpha = 0.0f;
    
    HPPRFlickrPhotoProvider *provider = [HPPRFlickrPhotoProvider sharedInstance];
    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeFlickr];

    [self willSignInToSocialSource:socialSource notifyDelegate:notifyDelegate];

    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self didSignInToSocialSource:socialSource notifyDelegate:notifyDelegate];

            [self presentPhotoGalleryWithSettings:^(HPPRSelectPhotoCollectionViewController *viewController) {
                viewController.provider = provider;
            }];

            NSDictionary *user = [HPPRFlickrLoginProvider sharedInstance].user;
            self.user = user;
            
        } else {
            if ([error code] == HPPR_ERROR_NO_INTERNET_CONNECTION) {
                [self showNoConnectionAvailableAlert];
                [self didFailSignInToSocialSource:socialSource notifyDelegate:notifyDelegate];
            } else if (error) {
                [self didFailSignInToSocialSource:socialSource notifyDelegate:notifyDelegate];
            } else {
                [self didSignOutToSocialSource:socialSource notifyDelegate:notifyDelegate];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeFromSuperview];
                [self enableSignIn];
            });
        }
    }];
}

- (void)enableSignIn
{
    [UIView animateWithDuration:0.5f animations:^{
        self.signInView.alpha = 1.0f;
    } completion:nil];
}

- (void)showLogin
{
    PGSocialSource *socialSource = [[PGSocialSourcesManager sharedInstance] socialSourceByType:PGSocialSourceTypeFlickr];
    [self willSignInToSocialSource:socialSource];

    [HPPRFlickrLoginProvider sharedInstance].viewController = self;
    [[HPPRFlickrLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self didSignInToSocialSource:socialSource];
            [self showPhotoGalleryNotifyDelegate:NO];
        } else if ((nil != error) && (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code)) {
            [self showNoConnectionAvailableAlert];
            [self didFailSignInToSocialSource:socialSource];
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
    
    HPPRFlickrPhotoProvider *provider = [HPPRFlickrPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:[self.user objectForKey:kFlickrUserNameKey] userId:[self.user objectForKey:kFlickrUserIdKey]];
    
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

- (BOOL)selectPhotoCollectionViewControllerShouldRequestOnlyLowResolutionImage:(HPPRSelectPhotoCollectionViewController *)selectPhotoCollectionViewController {
    return YES;
}

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, PGLandingPageViewControllerCollectionViewBottomInset, 0);
}

@end
