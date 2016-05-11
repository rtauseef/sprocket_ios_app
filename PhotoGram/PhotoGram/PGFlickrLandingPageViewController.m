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

#import <HPPRFlickrPhotoProvider.h>
#import <HPPRFlickrLoginProvider.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import <HPPRSelectAlbumTableViewController.h>
#import <HPPRCacheService.h>
#import <HPPRFlickrAlbum.h>
#import "PGFlickrLandingPageViewController.h"
#import "PGAppDelegate.h"
#import "PGAnalyticsManager.h"
#import "PGSelectTemplateViewController.h"
#import "SWRevealViewController.h"
#import "PGSideBarMenuTableViewController.h"
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckProviderNotification:) name:CHECK_PROVIDER_NOTIFICATION object:nil];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"DefaultButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f)];
    [self.signInButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self setLinkForLabel:self.termsLabel range:[self.termsLabel.text rangeOfString:NSLocalizedString(@"Terms of Service", @"Phrase to make link for terms of service of the landing page") options:NSCaseInsensitiveSearch]];
    
    [self checkFlickr];
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
            [self checkFlickr];
        });
    }
}

#pragma mark - Utils

- (void)checkFlickr
{
    UIActivityIndicatorView *spinner = [self.view addSpinner];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    self.signInView.alpha = 0.0f;
    
    HPPRFlickrPhotoProvider *provider = [HPPRFlickrPhotoProvider sharedInstance];

    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
            
            HPPRSelectAlbumTableViewController *vc = (HPPRSelectAlbumTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectAlbumTableViewController"];
            
            UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
            
            vc.navigationItem.leftBarButtonItem = hamburgerButtonItem;
            
            vc.delegate = self;
            
            vc.provider = provider;
            
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
            [self checkFlickr];
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
    PGSelectTemplateViewController *vc = (PGSelectTemplateViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGSelectTemplateViewController"];
    
    HPPRFlickrPhotoProvider *provider = [HPPRFlickrPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:[self.user objectForKey:kFlickrUserNameKey] userId:[self.user objectForKey:kFlickrUserIdKey]];
    vc.source = source;
    vc.selectedPhoto = image;
    vc.media = media;
    
    [self.navigationController pushViewController:vc animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

@end
