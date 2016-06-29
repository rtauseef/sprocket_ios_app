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
#import "SWRevealViewController.h"
#import "PGSideBarMenuTableViewController.h"
#import "PGLandingSelectorPageViewController.h"
#import "PGSurveyManager.h"
#import "PGWebViewerViewController.h"
#import "UIViewController+Trackable.h"
#import "PGCameraManager.h"

#import <MP.h>

#define IPHONE_5_HEIGHT 568 // pixels

@interface PGLandingMainPageViewController () <PGSurveyManagerDelegate, PGWebViewerViewControllerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) PGOverlayCameraViewController *cameraOverlay;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *flickrButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;

@end

@implementation PGLandingMainPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trackableScreenName = @"Main Landing Page";
    
    self.imageView = [[UIImageView alloc] init];
    
    [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:self.imageView];
    
    [self.view sendSubviewToBack:self.imageView];
    
    NSDictionary *viewsDictionary = @{@"imageView":self.imageView};
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[imageView]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[imageView]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"Hamburger"] forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:button];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[button(64)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[button(64)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    
    
    [self setLinkForLabel:self.termsLabel range:[self.termsLabel.text rangeOfString:NSLocalizedString(@"Terms of Service", @"Phrase to make link for terms of service of the landing page") options:NSCaseInsensitiveSearch]];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    PGSurveyManager *surveyManager = [PGSurveyManager sharedInstance];
    surveyManager.messageTitle = NSLocalizedString(@"Tell us what you think of sprocket", nil);
    surveyManager.delegate = self;
    [surveyManager check];
    
    BOOL openFromNotification = ((PGAppDelegate *)[UIApplication sharedApplication].delegate).openFromNotification;
    if (openFromNotification) {
        [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
    }
    
#ifndef APP_STORE_BUILD

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    lpgr.minimumPressDuration = 2.0f; //seconds
    lpgr.delaysTouchesBegan = YES;
    lpgr.delegate = self;
    [self.view addGestureRecognizer:lpgr];

#endif
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self applyBackgroundImageWithBaseName:@"LandingPage"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuOpenedNotification:) name:MENU_OPENED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuClosedNotification:) name:MENU_CLOSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowSocialNetworkNotification:) name:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [self applyBackgroundImageWithBaseName:@"LandingPage"];
}

- (NSString *)imageSuffixBasedOnDevice
{
    NSString *suffix = @"-700";
    if (IS_IPAD) {
        if (IS_PORTRAIT) {
            suffix = @"-700-Portrait";
        } else {
            suffix = @"-700-Landscape";
        }
    } else if(IS_IPHONE_5) {
        suffix = @"-700-568h";
    } else if (IS_IPHONE_6) {
        suffix = @"-800-667h";
    } else if (IS_IPHONE_6_PLUS) {
        if (IS_PORTRAIT) {
            suffix = @"-800-Portrait-736h";
        } else {
            suffix = @"-800-Landscape-736h";
        }
    } else {
        PGLogError(@"Unsupported device");
    }
    
    return suffix;
}

- (void)applyBackgroundImageWithBaseName:(NSString *)baseName
{
    NSString *imageSuffix = [self imageSuffixBasedOnDevice];
    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", baseName, imageSuffix]];
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
    [[PGCameraManager sharedInstance] showCamera:self animated:YES completion:nil];
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
