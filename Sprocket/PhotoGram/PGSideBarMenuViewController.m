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

#import <MP.h>
#import <MessageUI/MessageUI.h>

#import "PGSideBarMenuViewController.h"

#import "PGAppAppearance.h"
#import "PGAnalyticsManager.h"
#import "PGBatteryImageView.h"
#import "PGHelpAndHowToViewController.h"
#import "PGRevealViewController.h"
#import "PGSideBarMenuItems.h"
#import "PGSocialSourcesManager.h"
#import "PGSocialSourcesMenuViewController.h"
#import "PGSurveyManager.h"
#import "PGWebViewerViewController.h"

#import "UIViewController+Trackable.h"

static NSString *PGSideBarMenuCellIdentifier = @"PGSideBarMenuCell";

CGFloat const kPGSideBarMenuLongScreenSizeHeaderHeight = 75.0f;
CGFloat const kPGSideBarMenuShortScreenSizeHeaderHeight = 52.0f;

@interface PGSideBarMenuViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, PGWebViewerViewControllerDelegate, MPSprocketDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainMenuTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIView *deviceStatusLED;
@property (weak, nonatomic) IBOutlet UILabel *deviceConnectivityLabel;
@property (weak, nonatomic) IBOutlet PGBatteryImageView *deviceBatteryLevel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *collapseButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collapseButtonHeightConstraint;

@end

@implementation PGSideBarMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trackableScreenName = @"Side Bar Menu Screen";
    
    [PGAppAppearance addGradientBackgroundToView:self.view];
    
    if (IS_IPHONE_4) {
        self.headerHeight.constant = kPGSideBarMenuShortScreenSizeHeaderHeight;
    }
    
    self.overlayView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self unselectMenuTableViewCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unselectMenuTableViewCell)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    [self checkSprocketDeviceConnectivity];
    [self resizeViewAccordingRevealViewController];
    [self configureSocialSourcesMenu];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.overlayView.alpha != 0) {
        [self toggleSocialSourcesMenu];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDatasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PGSideBarMenuCellIdentifier];
    return [PGSideBarMenuItems configureCell:cell atIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kPGSideBarMenuItemsNumberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PGSideBarMenuItems heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case PGSideBarMenuCellSprocket: {
            [[MP sharedInstance] presentBluetoothDevicesFromController:self.revealViewController animated:YES completion:nil];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        case PGSideBarMenuCellBuyPaper:{
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kBuyPaperScreenName];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kBuyPaperURL]];
            break;
        }
        case PGSideBarMenuCellHowToAndHelp: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            PGHelpAndHowToViewController *viewController = (PGHelpAndHowToViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case PGSideBarMenuCellGiveFeedback: {
            [self sendEmail];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        case PGSideBarMenuCellTakeSurvey: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewerNavigationController"];
            
            PGWebViewerViewController *webViewerViewController = (PGWebViewerViewController *)navigationController.topViewController;
            webViewerViewController.trackableScreenName = @"Take Our Survey Screen";
            webViewerViewController.url = kSurveyURL;
            webViewerViewController.notifyUrl = kSurveyNotifyURL;
            webViewerViewController.delegate = self;
            [self presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        case PGSideBarMenuCellPrivacy: {
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kPrivacyStatementScreenName];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:kPrivacyStatementURL, [NSLocale countryID], [NSLocale languageID]]]];
            break;
        }
        case PGSideBarMenuCellAbout: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
            PGHelpAndHowToViewController *viewController = (PGHelpAndHowToViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PGAboutViewController"];
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - MPSprocketDelegate

- (void)didReceiveSprocketBatteryLevel:(NSUInteger)batteryLevel
{
    self.deviceBatteryLevel.level = batteryLevel;
}

#pragma mark - PGWebViewerViewControllerDelegate methods

- (void)webViewerViewControllerDidReachNotifyUrl:(PGWebViewerViewController *)webViewerViewController
{
    [[PGSurveyManager sharedInstance] setDisable:YES];
    [webViewerViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)unselectMenuTableViewCell
{
    [self.mainMenuTableView deselectRowAtIndexPath:[self.mainMenuTableView indexPathForSelectedRow] animated:YES];
}

- (void)checkSprocketDeviceConnectivity {
    if (IS_OS_8_OR_LATER) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
            BOOL shouldHideConnectivity = (numberOfPairedSprockets <= 0);
            
            self.deviceConnectivityLabel.hidden = shouldHideConnectivity;
            self.deviceStatusLED.hidden = shouldHideConnectivity;
            self.deviceBatteryLevel.hidden = shouldHideConnectivity;
            
            [[MP sharedInstance] checkSprocketForUpdates:self];
        });
    }
}

- (void)resizeViewAccordingRevealViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Resizing the table to the width revealed by the SWRevealViewController forces word-wrapping where necessary
        CGRect frame = self.view.frame;
        frame.size.width = self.revealViewController.rearViewRevealWidth;
        self.view.frame = frame;
    });
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendEmail
{
    if ([MFMailComposeViewController canSendMail]) {
        // Use the first six alpha-numeric characters in the device id as an identifier in the subject line
        NSString *deviceId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        NSCharacterSet *removeCharacters = [NSCharacterSet alphanumericCharacterSet].invertedSet;
        NSArray *remainingNumbers = [deviceId componentsSeparatedByCharactersInSet:removeCharacters];
        deviceId = [remainingNumbers componentsJoinedByString:@""];
        if( deviceId.length >= 6 ) {
            deviceId = [deviceId substringToIndex:6];
        }
        
        NSString *subjectLine = NSLocalizedString(@"Feedback on sprocket for iOS (Record Locator: %@)", @"Subject of the email send to technical support");
        subjectLine = [NSString stringWithFormat:subjectLine, deviceId];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.trackableScreenName = @"Feedback Screen";
        [mailComposeViewController.navigationBar setTintColor:[UIColor whiteColor]];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:subjectLine];
        [mailComposeViewController setMessageBody:@"" isHTML:NO];
        [mailComposeViewController setToRecipients:@[@"hpsnapshots@hp.com"]];
        
        [self presentViewController:mailComposeViewController animated:YES completion:^{
            // This is a workaround to set the text white in the status bar (otherwise by default would be black)
            // http://stackoverflow.com/questions/18945390/mfmailcomposeviewcontroller-in-ios-7-statusbar-are-black
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"You don’t have any account configured to send emails.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)barButtonCancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Social Sources Menu Methods

- (IBAction)overlayViewTapped:(id)sender {
    [self toggleSocialSourcesMenu];
}

- (IBAction)collapseButtonTapped:(id)sender
{
    [self toggleSocialSourcesMenu];
}

- (void)toggleSocialSourcesMenu
{
    [self.view layoutIfNeeded];
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI);
    CGFloat overlayAlpha = 0;
    
    if (self.overlayView.alpha != 0) {
        rotationTransform = CGAffineTransformMakeRotation(-(M_PI * 2));
        
        self.overlayView.userInteractionEnabled = NO;
        self.containerHeightConstraint.constant = [self closedSocialSourcesMenuHeightConstraint];
    } else {
        overlayAlpha = 0.7;
        
        self.overlayView.userInteractionEnabled = YES;
        self.containerHeightConstraint.constant = [self openedSocialSourcesMenuHeightConstraint];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.overlayView.alpha = overlayAlpha;
    }];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.collapseButton.imageView.transform = rotationTransform;
                     } completion:nil];
}

- (void)configureSocialSourcesMenu
{
    if ([self isSocialSourcesDefault]) {
        self.collapseButton.hidden = YES;
        self.containerHeightConstraint.constant = [self openedSocialSourcesMenuHeightConstraint];
    } else {
        self.collapseButton.hidden = NO;
        self.collapseButtonHeightConstraint.constant = kPGSocialSourcesMenuCellHeight;
        
        if (self.overlayView.alpha != 0) {
            self.containerHeightConstraint.constant = [self openedSocialSourcesMenuHeightConstraint];
        } else {
            self.containerHeightConstraint.constant = [self closedSocialSourcesMenuHeightConstraint];
        }
    }
}

- (CGFloat)openedSocialSourcesMenuHeightConstraint
{
    NSInteger socialSourcesCount = [PGSocialSourcesManager sharedInstance].enabledSocialSources.count;
    if (![self isSocialSourcesDefault]) {
        socialSourcesCount++;
    }
    
    return kPGSocialSourcesMenuCellHeight * socialSourcesCount;
}

- (CGFloat)closedSocialSourcesMenuHeightConstraint
{
    NSInteger socialSourcesCount = [PGSocialSourcesManager sharedInstance].enabledSocialSources.count;

    if (![self isSocialSourcesDefault]) {
        socialSourcesCount = kPGSocialSourcesMenuDefaultThreshold;
    }
    
    return kPGSocialSourcesMenuCellHeight * socialSourcesCount;
}

- (BOOL)isSocialSourcesDefault
{
    return [PGSocialSourcesManager sharedInstance].enabledSocialSources.count <= kPGSocialSourcesMenuDefaultThreshold;
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
