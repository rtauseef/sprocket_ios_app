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
#import "PGLandingSelectorPageViewController.h"
#import "PGSurveyManager.h"
#import "PGWebViewerViewController.h"
#import "UIViewController+Trackable.h"
#import "PGCameraManager.h"
#import "PGAnalyticsManager.h"
#import "PGSideBarMenuItems.h"
#import "PGSocialSourcesCircleView.h"
#import "PGSocialSourcesManager.h"
#import "NSLocale+Additions.h"
#import "UIFont+Style.h"
#import "PGLinkReaderViewController.h"

#import <MP.h>

#define IPHONE_5_HEIGHT 568 // pixels

NSInteger const kSocialSourcesUISwitchThreshold = 4;

@interface PGLandingMainPageViewController () <PGSurveyManagerDelegate, PGWebViewerViewControllerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, MPSprocketDelegate, PGSocialSourcesCircleViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *cameraBackgroundView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurredView;
@property (weak, nonatomic) IBOutlet UIView *landingButtonsView;
@property (weak, nonatomic) IBOutlet UIView *cameraButtonsView;
@property (weak, nonatomic) IBOutlet UIButton *hamburgerButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *flickrButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (weak, nonatomic) IBOutlet PGSocialSourcesCircleView *socialSourcesCircleView;

@property (weak, nonatomic) IBOutlet UIView *socialSourcesHorizontalContainer;
@property (weak, nonatomic) IBOutlet UIView *socialSourcesCircularContainer;
@property (weak, nonatomic) IBOutlet UIView *socialSourcesVerticalContainer;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelBottomConstraint;

@end

@implementation PGLandingMainPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.hamburgerButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    self.trackableScreenName = @"Main Landing Page";
    self.termsLabel.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    if ([NSLocale isSurveyAvailable]) {
        PGSurveyManager *surveyManager = [PGSurveyManager sharedInstance];
        surveyManager.messageTitle = NSLocalizedString(@"Tell us what you think of sprocket", nil);
        surveyManager.delegate = self;
        [surveyManager check];
    }

    self.socialSourcesCircleView.delegate = self;

    [self setSocialSourcesLayout];

    BOOL openFromNotification = ((PGAppDelegate *)[UIApplication sharedApplication].delegate).openFromNotification;
    if (openFromNotification) {
        [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
    }
    
    [self.view layoutIfNeeded];
    [PGAppAppearance addGradientBackgroundToView:self.view];
    
    [self addLongPressGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLinkSettingsChanged:)  name:kPGLinkSettingsChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowSocialNetworkNotification:) name:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCameraButtons) name:kPGCameraManagerCameraClosed object:nil];
    
    __weak PGLandingMainPageViewController *weakSelf = self;
    [[PGCameraManager sharedInstance] checkCameraPermission:^{
        [[PGCameraManager sharedInstance] addCameraButtonsOnView:weakSelf.cameraButtonsView];
        [[PGCameraManager sharedInstance] addCameraToView:weakSelf.cameraBackgroundView presentedViewController:weakSelf];
        [PGCameraManager sharedInstance].isBackgroundCamera = YES;
    } andFailure:^{
        self.blurredView.alpha = 0;
        self.cameraBackgroundView.alpha = 0;
    }];

    [self setSocialSourcesLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[MP sharedInstance] checkSprocketForUpdates:self];
    
    [[PGCameraManager sharedInstance] startCamera];
}

- (void)didCompareSprocketWithLatestFirmwareVersion:(NSString *)deviceName batteryLevel:(NSUInteger)batteryLevel needsUpgrade:(BOOL)needsUpgrade
{
    static BOOL promptedForReflash = NO;
    
    if (!promptedForReflash  &&  needsUpgrade) {
        
        promptedForReflash = YES;
        
        NSString *title = NSLocalizedString(@"Sprocket Printer Firmware Upgrade Available", @"Title for dialog that prompts user to ugrade device firmware");
        if ([MP sharedInstance].minimumSprocketBatteryLevelForUpgrade < batteryLevel) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:NSLocalizedString(@"Tap Upgrade to continue.", @"Body for dialog that prompts user to ugrade device firmware")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upgrade", @"If pressed (on firmware upgrade dialog), firmware upgrade will begin")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [[MP sharedInstance] reflashBluetoothDevice:self.navigationController];
                                                             } ];
            [alertController addAction:okAction];
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"Allows user to decline firmware upgrade without taking any action")
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:nil];
            [alertController addAction:dismissAction];
            
            // Setting the preferred action is only available in iOS9 and later
            if ([alertController respondsToSelector:@selector(setPreferredAction:)]) {
                [alertController setPreferredAction:okAction];
            }
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            NSString * body = NSLocalizedString(@"To upgrade, charge sprocket printer to at least 75% and then go to 'sprocket' in the menu.", @"Body for dialog that prompts user to charge their battery and then upgrade their firmware.");
            body = [body stringByReplacingOccurrencesOfString:@"75" withString:[NSString stringWithFormat:@"%lu", (unsigned long)[MP sharedInstance].minimumSprocketBatteryLevelForUpgrade]];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:body
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Allows user close dialog")
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:nil];
            [alertController addAction:dismissAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
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

- (void)showSocialNetwork:(PGSocialSourceType)socialSourceType includeLogin:(BOOL)includeLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // push the LandingSelectorPage onto our nav stack
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
        PGLandingSelectorPageViewController *vc = (PGLandingSelectorPageViewController *)[sb instantiateViewControllerWithIdentifier:@"PGLandingSelectorPageViewController"];

        vc.socialSourceType = socialSourceType;
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

- (void)setSocialSourcesLayout
{
    // Holding the social sources circle while Qzone and Weibo are not ready for deployment
    
    NSInteger sourceCount = [[PGSocialSourcesManager sharedInstance] enabledSocialSources].count;
    if ([PGLinkSettings linkEnabled]) {
        sourceCount += 1;
    }
    
    self.socialSourcesVerticalContainer.hidden = YES;
    if (sourceCount > kSocialSourcesUISwitchThreshold) {
        self.socialSourcesHorizontalContainer.hidden = YES;
        self.socialSourcesCircularContainer.hidden = NO;
    } else {
        self.socialSourcesCircularContainer.hidden = YES;
        self.socialSourcesHorizontalContainer.hidden = NO;
    }
    
    // -> Begin temporary UI
    /*
     self.socialSourcesCircularContainer.hidden = YES;
     if ([NSLocale isChinese]) {
     self.socialSourcesHorizontalContainer.hidden = YES;
     
     if (IS_IPHONE_6 || IS_IPHONE_6_PLUS) {
     self.titleLabel.font = [UIFont HPSimplifiedLightFontWithSize:42.0];
     self.titleLabelBottomConstraint.constant = 73.0;
     }
     } else {
     self.socialSourcesVerticalContainer.hidden = YES;
     }
     */
    // <- End temporary UI
}

#pragma mark - Notifications

- (void)handleMenuOpenedNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.termsLabel.userInteractionEnabled = NO;
        self.instagramButton.userInteractionEnabled = NO;
        self.facebookButton.userInteractionEnabled = NO;
        self.flickrButton.userInteractionEnabled = NO;
        self.cameraRollButton.userInteractionEnabled = NO;
        self.socialSourcesCircleView.userInteractionEnabled = NO;
    });
    
}

- (void)handleMenuClosedNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.termsLabel.userInteractionEnabled = YES;
        self.instagramButton.userInteractionEnabled = YES;
        self.facebookButton.userInteractionEnabled = YES;
        self.flickrButton.userInteractionEnabled = YES;
        self.cameraRollButton.userInteractionEnabled = YES;
        self.socialSourcesCircleView.userInteractionEnabled = YES;
    });
}

- (void)handleLinkSettingsChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setSocialSourcesLayout];
    });
}

- (void)handleShowSocialNetworkNotification:(NSNotification *)notification
{
    PGSocialSourceType socialSourceType = [[notification.userInfo objectForKey:kSocialNetworkKey] unsignedIntegerValue];
    BOOL includeLogin = [[notification.userInfo objectForKey:kIncludeLoginKey] boolValue];
    
    [self showSocialNetwork:socialSourceType includeLogin:includeLogin];
}

#pragma mark - Gesture recognizers

- (IBAction)cameraRollTapped:(id)sender
{
    [self showSocialNetwork:PGSocialSourceTypeLocalPhotos includeLogin:NO];
}

- (IBAction)pituTapped:(id)sender
{
    [self showSocialNetwork:PGSocialSourceTypePitu includeLogin:NO];
}

- (IBAction)facebookTapped:(id)sender
{
    [self showSocialNetwork:PGSocialSourceTypeFacebook includeLogin:NO];
}

- (IBAction)instagramTapped:(id)sender
{
    [self showSocialNetwork:PGSocialSourceTypeInstagram includeLogin:NO];
}

- (IBAction)flickrTapped:(id)sender
{
    [self showSocialNetwork:PGSocialSourceTypeFlickr includeLogin:NO];
}

- (IBAction)linkScanTapped:(id)sender
{
    [self presentViewController:[PGLinkReaderViewController new] animated:YES completion:nil];
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
    } completion:^(BOOL finished){
        [PGCameraManager logMetrics];
    }];
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
        webViewerViewController.url = kSurveyURL;
        webViewerViewController.notifyUrl = kSurveyNotifyURL;
        webViewerViewController.delegate = self;
    }
}

- (void)webViewerViewControllerDidReachNotifyUrl:(PGWebViewerViewController *)webViewerViewController
{
    [[PGSurveyManager sharedInstance] setDisable:YES];

    [webViewerViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PGSocialSourcesCircleViewDelegate

- (void)socialCircleView:(PGSocialSourcesCircleView *)view didTapOnCameraButton:(UIButton *)button
{
    [self cameraTapped:button];
}

- (void)socialCircleView:(PGSocialSourcesCircleView *)view didTapOnLinkButton:(UIButton *)button
{
    [self linkScanTapped:button];
}

- (void)socialCircleView:(PGSocialSourcesCircleView *)view didTapOnSocialButton:(UIButton *)button withSocialSource:(PGSocialSource *)socialSource
{
    switch (socialSource.type) {
        case PGSocialSourceTypeFacebook:
            [self facebookTapped:button];
            break;
        case PGSocialSourceTypeInstagram:
            [self instagramTapped:button];
            break;
        case PGSocialSourceTypeFlickr:
            [self flickrTapped:button];
            break;
        case PGSocialSourceTypeLocalPhotos:
            [self cameraRollTapped:button];
            break;
        case PGSocialSourceTypeWeiBo:
            NSLog(@"WeiBo tapped");
            break;
        case PGSocialSourceTypeQzone:
            [self showSocialNetwork:PGSocialSourceTypeQzone includeLogin:NO];
            break;
        case PGSocialSourceTypePitu:
            [self pituTapped:button];
            break;
    }
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
