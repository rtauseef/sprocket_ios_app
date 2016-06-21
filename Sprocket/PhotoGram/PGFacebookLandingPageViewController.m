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

#import <FacebookSDK/FacebookSDK.h>
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
#import "PGSideBarMenuTableViewController.h"
#import "UIView+Animations.h"
#import "UIViewController+Trackable.h"

NSString * const kFacebookUserNameKey = @"name";
NSString * const kFacebookUserIdKey = @"id";

@interface PGFacebookLandingPageViewController () <HPPRSelectPhotoCollectionViewControllerDelegate>

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckProviderNotification:) name:CHECK_PROVIDER_NOTIFICATION object:nil];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"DefaultButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 4.0f, 0.0f, 4.0f)];
    [self.signInButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self setLinkForLabel:self.termsLabel range:[self.termsLabel.text rangeOfString:NSLocalizedString(@"Terms of Service", @"Phrase to make link for terms of service of the landing page") options:NSCaseInsensitiveSearch]];
    
    [self checkFacebook];
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

    if ([[HPPRFacebookPhotoProvider sharedInstance].name isEqualToString:socialNetwork]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self checkFacebook];
    }
}

#pragma mark - Utils

- (void)checkFacebook
{
    self.spinner = [self.view addSpinner];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    self.signInView.alpha = 0.0f;
    
    HPPRFacebookPhotoProvider *provider = [HPPRFacebookPhotoProvider sharedInstance];
    
    [provider.loginProvider checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        __block NSString *alertText;
        __block NSString *alertTitle;
        
        if (loggedIn) {
            
            [provider userInfoWithRefresh:NO andCompletion:^(NSDictionary<FBGraphUser> *userInfo, NSError *error) {
                
                if (!error) {
                    provider.user = userInfo;
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
                    
                    HPPRSelectAlbumTableViewController *vc = (HPPRSelectAlbumTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPRSelectAlbumTableViewController"];
                    
                    UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
                    
                    vc.navigationItem.leftBarButtonItem = hamburgerButtonItem;
                    
                    vc.delegate = self;
                    
                    vc.provider = provider;
                    
                    [self.spinner removeFromSuperview];

                    [self.navigationController pushViewController:vc animated:NO];
                    
                    
                } else {
                    PGLogError(@"Error retrieving user info");
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors
                    
                    [FBSession.activeSession closeAndClearTokenInformation];
                    
                    [self.spinner removeFromSuperview];
                    
                    alertTitle = NSLocalizedString(@"Error", nil);
                    alertText = NSLocalizedString(@"Error retrieving user information.", @"Error retrieving the facebook user information");
                    [self showMessage:alertText withTitle:alertTitle];
                    
                    [self enableSignIn];
                    return;
                }
            }];
            
        } else if (error) {
            [self.spinner removeFromSuperview];
            [self checkError:error];
            [FBSession.activeSession closeAndClearTokenInformation];
            [self enableSignIn];
            
        } else {
            [self.spinner removeFromSuperview];
            [self enableSignIn];
        }
    }];
}

- (void)checkError:(NSError *)error
{
    NSString *alertTitle;
    NSString *alertText;
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
        alertTitle = NSLocalizedString(@"Error", nil);
        alertText = [FBErrorUtility userMessageForError:error];
        [self showMessage:alertText withTitle:alertTitle];
    } else {
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            PGLogInfo(@"User cancelled login");
        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
            alertTitle = NSLocalizedString(@"Session Error", nil);
            alertText = NSLocalizedString(@"Your current session is no longer valid. Please log in again.", nil);
            [self showMessage:alertText withTitle:alertTitle];
        } else if (HPPR_ERROR_NO_INTERNET_CONNECTION == error.code) {
            [self showNoConnectionAvailableAlert];
        } else {
            NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
            alertTitle = NSLocalizedString(@"Session Error", nil);
            alertText = [NSString stringWithFormat:NSLocalizedString(@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", @"Shows the description of the error"), [errorInformation objectForKey:@"message"]];
            [self showMessage:alertText withTitle:alertTitle];
        }
    }
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}

- (void)enableSignIn
{
    [UIView animateWithDuration:0.5f animations:^{
        self.signInView.alpha = 1.0f;
    } completion:nil];
}

- (void)showLogin
{
    [[HPPRFacebookLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self checkFacebook];
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
    
    HPPRFacebookPhotoProvider *provider = [HPPRFacebookPhotoProvider sharedInstance];
    [[PGAnalyticsManager sharedManager] switchSource:provider.name userName:[provider.user objectForKey:kFacebookUserNameKey] userId:[provider.user objectForKey:kFacebookUserIdKey]];
    
    [self presentViewController:previewViewController animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DISABLE_PAGE_CONTROLLER_FUNCTIONALITY_NOTIFICATION object:nil];
}

@end
