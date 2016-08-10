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
#import <HPPRInstagram.h>
#import <HPPRInstagramUser.h>
#import <HPPRInstagramUserMedia.h>
#import <HPPRInstagramPhotoProvider.h>
#import <HPPRInstagramLoginProvider.h>
#import <HPPRSelectPhotoCollectionViewController.h>
#import "PGInstagramLandingPageViewController.h"
#import "SWRevealViewController.h"
#import "PGAnalyticsManager.h"
#import "PGPreviewViewController.h"
#import "PGSideBarMenuTableViewController.h"
#import "UIViewController+Trackable.h"
#import "UIView+Animations.h"
#import "UIImage+ImageResize.h"

@interface PGInstagramLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *signInView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userId;

@end

@implementation PGInstagramLandingPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Instagram Landing Page Screen";
    
    self.view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.signInView.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    self.termsLabel.textColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRPrimaryLabelColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckProviderNotification:) name:CHECK_PROVIDER_NOTIFICATION object:nil];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"DefaultButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f)];
    [self.signInButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self setLinkForLabel:self.termsLabel range:[self.termsLabel.text rangeOfString:NSLocalizedString(@"Terms of Service", @"Phrase to make link for terms of service of the landing page") options:NSCaseInsensitiveSearch]];

    [self checkInstagramWithCompletion:^{
        [self prefetchProviderData];
    }];
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
    
    if ([[HPPRInstagramPhotoProvider sharedInstance].name isEqualToString:socialNetwork]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self checkInstagramWithCompletion:nil];
    }
}

#pragma mark - Utils

- (void)checkInstagramWithCompletion:(void(^)(void))completion
{
    HPPRInstagramPhotoProvider *provider = [HPPRInstagramPhotoProvider sharedInstance];

    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            UIActivityIndicatorView *spinner = [self.view addSpinner];
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;

            self.signInView.alpha = 0.0f;
            
            [HPPRInstagramUser userProfileWithId:@"self" completion:^(NSString *userName, NSString *userId, NSString *profilePictureUrl, NSNumber *posts, NSNumber *followers, NSNumber *following) {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    if (userName == nil) {
                        [[HPPRInstagram sharedClient] setAccessToken:nil];
                        [spinner removeFromSuperview];
                        [self enableSignIn];
                        if (completion) {
                            completion();
                        }
                    } else {
                        self.userName = userName;
                        self.userId = userId;
                        
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
                        
                        HPPRSelectPhotoCollectionViewController *vc = (HPPRSelectPhotoCollectionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectPhotoCollectionViewController"];
                        
                        UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
                        
                        vc.navigationItem.leftBarButtonItem = hamburgerButtonItem;
                        
                        vc.delegate = self;
                        
                        [provider initForStandardDisplay];
                        vc.provider = provider;
                        
                        [spinner removeFromSuperview];

                        [self.navigationController pushViewController:vc animated:NO];
                        
                       
                    }
                });
            }];
        } else {
            if ((nil != error) && (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code)) {
                [self showNoConnectionAvailableAlert];
            }
            
            [self enableSignIn];
            if (completion) {
                completion();
            }
        }
    }];
}

- (void)prefetchProviderData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PROVIDER_STARTUP_NOTIFICATION object:nil];
}

- (void)enableSignIn
{
    [UIView animateWithDuration:0.5f animations:^{
        self.signInView.alpha = 1.0f;
    } completion:nil];
}

- (void)showLogin
{
    [HPPRInstagramLoginProvider sharedInstance].viewController = self;
    [[HPPRInstagramLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self checkInstagramWithCompletion:nil];
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
    previewViewController.media = media;

    HPPRInstagramPhotoProvider *provider = [HPPRInstagramPhotoProvider sharedInstance];

    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:self.userName userId:self.userId];
    
    [self presentViewController:previewViewController animated:YES completion:nil];    
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

- (UIEdgeInsets)collectionViewContentInset {
    return UIEdgeInsetsMake(0, 0, PGLandingPageViewControllerCollectionViewBottomInset, 0);
}

@end
