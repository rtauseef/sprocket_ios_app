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
#import <HPPRFacebookPhotoProvider.h>
#import <HPPRInstagramPhotoProvider.h>
#import <HPPRCameraRollPhotoProvider.h>

#import "PGLandingMainPageViewController.h"
#import "PGAppDelegate.h"
#import "PGAppAppearance.h"
#import "SWRevealViewController.h"
#import "PGSideBarMenuTableViewController.h"
#import "PGLandingSelectorPageViewController.h"
#import "PGSurveyManager.h"
#import "PGWebViewerViewController.h"
#import "UIViewController+Trackable.h"
#import "PGCameraManager.h"

#import <MP.h>

#define IPHONE_5_HEIGHT 568 // pixels

@interface PGLandingMainPageViewController () <PGSurveyManagerDelegate, PGWebViewerViewControllerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MPSprocketDelegate>

@property (strong, nonatomic) IBOutlet UIView *cameraBackgroundView;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *blurredView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *landingButtonsView;
@property (strong, nonatomic) IBOutlet UIView *cameraButtonsView;

@property (strong, nonatomic) IBOutlet UIButton *hamburgerButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (strong, nonatomic) IBOutlet UIButton *instagramButton;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *flickrButton;
@property (strong, nonatomic) IBOutlet UIButton *cameraRollButton;

@end

@implementation PGLandingMainPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.hamburgerButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    self.trackableScreenName = @"Main Landing Page";
    self.termsLabel.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    PGSurveyManager *surveyManager = [PGSurveyManager sharedInstance];
    surveyManager.messageTitle = NSLocalizedString(@"Tell us what you think of sprocket", nil);
    surveyManager.delegate = self;
    [surveyManager check];
    
    BOOL openFromNotification = ((PGAppDelegate *)[UIApplication sharedApplication].delegate).openFromNotification;
    if (openFromNotification) {
        [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
    }
    
    [self.view layoutIfNeeded];
    [PGAppAppearance addGradientBackgroundToView:self.view];
    
    [self addLongPressGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowSocialNetworkNotification:) name:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCameraButtons) name:kPGCameraManagerCameraClosed object:nil];
    
    __weak PGLandingMainPageViewController *weakSelf = self;
    [[PGCameraManager sharedInstance] checkCameraPermission:^{
        [[PGCameraManager sharedInstance] addCameraButtonsOnView:weakSelf.cameraButtonsView];
        [[PGCameraManager sharedInstance] addCameraToView:weakSelf.cameraBackgroundView presentedViewController:weakSelf];
    } andFailure:^{
        [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
        self.blurredView.alpha = 0;
        self.cameraBackgroundView.alpha = 0;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[MP sharedInstance] checkSprocketForFirmwareUpgrade:self];
    
    [[PGCameraManager sharedInstance] startCamera];
}

- (void)didCompareSprocketWithLatestFirmwareVersion:(NSString *)deviceName needsUpgrade:(BOOL)needsUpgrade
{
    static BOOL promptedForReflash = NO;
    
    if (!promptedForReflash  &&  needsUpgrade) {
        
        promptedForReflash = YES;
        
        NSString *firmwareUpgradeTitle = NSLocalizedString(@"Firmware Upgrade", @"Title for dialog that prompts user to ugrade device firmware");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", deviceName, firmwareUpgradeTitle]
                                                                                 message:NSLocalizedString(@"Download the printer firmware upgrade?", @"Body for dialog that prompts user to ugrade device firmware")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"Allows user to decline firmware upgrade without taking any action")
                                                                style:UIAlertActionStyleCancel
                                                              handler:nil];
        [alertController addAction:dismissAction];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"If pressed (on firmware upgrad dialog), firmware upgrade will begin")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [[MP sharedInstance] reflashBluetoothDevice:self.navigationController];
                                                         } ];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self hideCameraButtons];
    [[PGCameraManager sharedInstance] stopCamera];
}

#pragma mark - Private Methods

- (void)addLongPressGesture {
    #ifndef APP_STORE_BUILD
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
        lpgr.minimumPressDuration = 2.0f; //seconds
        lpgr.delaysTouchesBegan = YES;
        lpgr.delegate = self;
        [self.view addGestureRecognizer:lpgr];
        
    #endif
}

- (void)showSocialNetwork:(NSString *)socialNetwork includeLogin:(BOOL)includeLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // push the LandingSelectorPage onto our nav stack
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        PGLandingSelectorPageViewController *vc = (PGLandingSelectorPageViewController *)[sb instantiateViewControllerWithIdentifier:@"PGLandingSelectorPageViewController"];
        
        vc.socialNetwork = socialNetwork;
        vc.includeLogin = includeLogin;
        
        [UIView transitionWithView:self.navigationController.view
                          duration:0.25f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.navigationController pushViewController:vc animated:NO];
                        }
                        completion:nil];
    });
}

#pragma mark - Notifications

- (void)handleMenuOpenedNotification:(NSNotification *)notification
{
    self.termsLabel.userInteractionEnabled = NO;
    self.instagramButton.userInteractionEnabled = NO;
    self.facebookButton.userInteractionEnabled = NO;
    self.flickrButton.userInteractionEnabled = NO;
    self.cameraRollButton.userInteractionEnabled = NO;    
}

- (void)handleMenuClosedNotification:(NSNotification *)notification
{
    self.termsLabel.userInteractionEnabled = YES;
    self.instagramButton.userInteractionEnabled = YES;
    self.facebookButton.userInteractionEnabled = YES;
    self.flickrButton.userInteractionEnabled = YES;
    self.cameraRollButton.userInteractionEnabled = YES;
}

- (void)handleShowSocialNetworkNotification:(NSNotification *)notification
{
    NSString *socialNetwork = [notification.userInfo objectForKey:kSocialNetworkKey];
    NSNumber *includeLogin = [notification.userInfo objectForKey:kIncludeLoginKey];
    
    [self showSocialNetwork:socialNetwork includeLogin:[includeLogin boolValue]];
}

#pragma mark - Gesture recognizers

- (IBAction)cameraRollTapped:(id)sender
{
    [self showSocialNetwork:[HPPRCameraRollPhotoProvider sharedInstance].name includeLogin:NO];
}

- (IBAction)facebookTapped:(id)sender
{
    [self showSocialNetwork:[HPPRFacebookPhotoProvider sharedInstance].name includeLogin:NO];
}

- (IBAction)instagramTapped:(id)sender
{
    [self showSocialNetwork:[HPPRInstagramPhotoProvider sharedInstance].name includeLogin:NO];
}

- (IBAction)flickrTapped:(id)sender
{
    [self showSocialNetwork:[HPPRFlickrPhotoProvider sharedInstance].name includeLogin:NO];
}

- (IBAction)cameraTapped:(id)sender
{
    __weak PGLandingMainPageViewController *weakSelf = self;
    [[PGCameraManager sharedInstance] checkCameraPermission:^{
        [weakSelf showCameraButtons];
    } andFailure:^{
        [[PGCameraManager sharedInstance] showCameraPermissionFailedAlert];
        weakSelf.blurredView.alpha = 0;
        weakSelf.cameraBackgroundView.alpha = 0;
    }];
}

- (void)showCameraButtons {
    [UIView animateWithDuration:0.3 animations:^{
        self.blurredView.alpha = 0;
        self.landingButtonsView.alpha = 0;
        self.cameraButtonsView.alpha = 1;
    } completion:nil];
}

- (void)hideCameraButtons {
    [UIView animateWithDuration:0.3 animations:^{
        self.blurredView.alpha = 1;
        self.landingButtonsView.alpha = 1;
        self.cameraButtonsView.alpha = 0;
    } completion:nil];
}

#pragma mark - PGSurveyManagerDelegate

- (void)surveyManagerUserDidSelectAccept:(PGSurveyManager *)surveyManager
{
    [self performSegueWithIdentifier:@"TakeOurSurveySegue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TakeOurSurveySegue"]) {
        UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
        
        PGWebViewerViewController *webViewerViewController = (PGWebViewerViewController *)navigationController.topViewController;
        webViewerViewController.trackableScreenName = @"Take Our Survey Screen";
        webViewerViewController.url = kTakeOurSurveyURL;
        webViewerViewController.notifyUrl = kTakeOurSurveyNotifyURL;
        webViewerViewController.delegate = self;
    }
}

- (void)webViewerViewControllerDidReachNotifyUrl:(PGWebViewerViewController *)webViewerViewController
{
    [[PGSurveyManager sharedInstance] setDisable:YES];

    [webViewerViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Reset user defaults

#ifndef APP_STORE_BUILD

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]];
}

- (BOOL)longPressGestureRecognized:(UIGestureRecognizer *)gestureRecognizer
{
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        if (NSClassFromString(@"UIAlertController") != nil) {
            UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Reset Application", nil) message:NSLocalizedString(@"This will clear all previously saved options.", nil) preferredStyle:style];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reset", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self resetUserDefaults];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];    }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
            actionSheet.title = NSLocalizedString(@"Reset Application", nil);
            actionSheet.delegate = self;
            actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Reset", nil)];
            actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
            [actionSheet showInView:self.view];
        }
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        [self resetUserDefaults];
    }
}

- (void)resetUserDefaults
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

#endif

@end
