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
    
    [self checkFlickrAndAlbums:NO];
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
    NSString *socialNetwork = [notification.userInfo objectForKey:kSocialNetworkKey];
    
    if ([[HPPRFlickrPhotoProvider sharedInstance].name isEqualToString:socialNetwork]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkFlickrAndAlbums:NO];
        });
    }
}

- (void)showAlbums
{
    [self checkFlickrAndAlbums:YES];
}

#pragma mark - Utils

- (void)checkFlickrAndAlbums:(BOOL)forAlbums
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;

    self.signInView.alpha = 0.0f;
    
    HPPRFlickrPhotoProvider *provider = [HPPRFlickrPhotoProvider sharedInstance];

    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
            
            UIViewController *vc = nil;
            if (forAlbums) {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectAlbumTableViewController"];
                ((HPPRSelectAlbumTableViewController *)vc).delegate = self;
                ((HPPRSelectAlbumTableViewController *)vc).provider = provider;
            } else {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
                ((HPPRSelectPhotoCollectionViewController *)vc).delegate = self;
                ((HPPRSelectPhotoCollectionViewController *)vc).provider = provider;
            }
            
            UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
            
            vc.navigationItem.leftBarButtonItem = hamburgerButtonItem;
            
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [spinner removeFromSuperview];
                [self.navigationController pushViewController:vc animated:NO];
            });
            NSDictionary *user = [HPPRFlickrLoginProvider sharedInstance].user;
            self.user = user;
            
        } else {
            if ((nil != error) && (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code)) {
                [self showNoConnectionAvailableAlert];
            }
            
            // Why to call logout?
            //[[HPPRFlickrLoginProvider sharedInstance] logoutWithCompletion:nil];
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
    [HPPRFlickrLoginProvider sharedInstance].viewController = self;
    [[HPPRFlickrLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self checkFlickrAndAlbums:NO];
        } else if ((nil != error) && (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code)) {
            [self showNoConnectionAvailableAlert];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    PGPreviewViewController *previewViewController = (PGPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGPreviewViewController"];
    previewViewController.selectedPhoto = image;
    previewViewController.source = source;
    
    HPPRFlickrPhotoProvider *provider = [HPPRFlickrPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:[self.user objectForKey:kFlickrUserNameKey] userId:[self.user objectForKey:kFlickrUserIdKey]];
    
    [self presentViewController:previewViewController animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, PGLandingPageViewControllerCollectionViewBottomInset, 0);
}

@end
