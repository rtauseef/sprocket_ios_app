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
    [self checkQzoneAndAlbums:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PhotoProvider methods

- (void)showAlbums
{
    [self checkQzoneAndAlbums:YES];
}

- (void)checkQzoneAndAlbums:(BOOL)forAlbums
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
    
    HPPRQzonePhotoProvider *provider = [HPPRQzonePhotoProvider sharedInstance];
    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            UIViewController *vc = nil;
            if (forAlbums) {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectAlbumTableViewController"];
                ((HPPRSelectAlbumTableViewController *)vc).delegate = self;
                ((HPPRSelectAlbumTableViewController *)vc).provider = provider;
                
            } else {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
                ((HPPRSelectPhotoCollectionViewController *)vc).delegate = self;
                ((HPPRSelectPhotoCollectionViewController *)vc).provider = provider;
                ((HPPRSelectPhotoCollectionViewController *)vc).customNoPhotosMessage = NSLocalizedString(@"No Qzone app images found", @"Message displayed when no images from the Qzone app can be found");
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [spinner removeFromSuperview];
                [self.navigationController pushViewController:vc animated:YES];
            });
        } else {
            if ((nil != error) && (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code)) {
                [self showNoConnectionAvailableAlert];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeFromSuperview];
                [self enableSignIn];
            });
        }
    }];
}

- (void)showLogin
{
    [[HPPRQzoneLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self checkQzoneAndAlbums:NO];
            [[PGAnalyticsManager sharedManager] trackAuthRequestActivity:kEventAuthRequestOkAction
                                                                  device:kEventAuthRequestPhotosLabel];
        } else {
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
    NSString *socialNetwork = [notification.userInfo objectForKey:kSocialNetworkKey];
    
    if ([[HPPRQzonePhotoProvider sharedInstance].name isEqualToString:socialNetwork]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self checkQzoneAndAlbums:NO];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = image;
    previewViewController.source = source;
    
    [self presentViewController:previewViewController animated:YES completion:nil];
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
    [self checkQzoneAndAlbums:NO];
}


@end
