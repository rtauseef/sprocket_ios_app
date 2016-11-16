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
#import "PGSurveyManager.h"
#import "PGWebViewerViewController.h"

#import "NSLocale+Additions.h"
#import "UIViewController+Trackable.h"
#import "UIColor+Style.h"

static NSString *PGSideBarMenuCellIdentifier = @"PGSideBarMenuCell";

CGFloat const kPGSideBarMenuLongScreenSizeHeaderHeight = 75.0f;
CGFloat const kPGSideBarMenuShortScreenSizeHeaderHeight = 52.0f;

CGFloat const kPGSideBarMenuRegularCellHeight = 52.0f;
CGFloat const kPGSideBarMenuSmallCellHeight = 42.0f;
CGFloat const kPGSideBarMenuSmallSocialHeight = 40.0f;
CGFloat const kPGSideBarMenuDeviceConnectivityLabelX = 58.0f;
CGFloat const kPGSideBarMenuSignOutSpacing = 1.0f;

NSInteger const kPGSideBarMenuNumberOfRows = 7;

NSString * const kPrivacyStatementURL = @"http://www8.hp.com/%@/%@/privacy/privacy.html";
NSString * const kBuyPaperURL = @"http://www.hp.com/go/ZINKphotopaper";
NSString * const kSurveyURL = @"https://www.surveymonkey.com/r/Q99S6P5";
NSString * const kSurveyNotifyURL = @"www.surveymonkey.com/r/close-window";
NSString * const kSocialNetworkKey = @"social-network";
NSString * const kIncludeLoginKey = @"include-login";
NSString * const kBuyPaperScreenName = @"Buy Paper Screen";
NSString * const kPrivacyStatementScreenName = @"Privacy Statement Screen";
 

typedef NS_ENUM(NSInteger, PGSideBarMenuCell) {
    PGSideBarMenuCellSprocket,
    PGSideBarMenuCellBuyPaper,
    PGSideBarMenuCellHowToAndHelp,
    PGSideBarMenuCellGiveFeedback,
    PGSideBarMenuCellTakeSurvey,
    PGSideBarMenuCellPrivacy,
    PGSideBarMenuCellAbout,
};

@interface PGSideBarMenuViewController () <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, PGWebViewerViewControllerDelegate, MPSprocketDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainMenuTableView;

@property (weak, nonatomic) IBOutlet UIView *deviceStatusLED;
@property (weak, nonatomic) IBOutlet UILabel *deviceConnectivityLabel;
@property (weak, nonatomic) IBOutlet PGBatteryImageView *deviceBatteryLevel;

@end

@implementation PGSideBarMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trackableScreenName = @"Side Bar Menu Screen";
    
    [PGAppAppearance addGradientBackgroundToView:self.view];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDatasource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PGSideBarMenuCellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    
    cell.selectedBackgroundView = selectionColorView;
    
    switch (indexPath.row) {
        case PGSideBarMenuCellSprocket:
            cell.textLabel.text = NSLocalizedString(@"sprocket", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuSprocket"];
            break;
        case PGSideBarMenuCellBuyPaper:
            cell.textLabel.text = NSLocalizedString(@"Buy Paper", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuBuyPaper"];
            break;
        case PGSideBarMenuCellHowToAndHelp:
            cell.textLabel.text = NSLocalizedString(@"How to & Help", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuHowToHelp"];
            break;
        case PGSideBarMenuCellGiveFeedback:
            cell.textLabel.text = NSLocalizedString(@"Give Feedback", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuGiveFeedback"];
            break;
        case PGSideBarMenuCellTakeSurvey:
            cell.textLabel.text = NSLocalizedString(@"Take Survey", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuTakeSurvey"];
            break;
        case PGSideBarMenuCellPrivacy:
            cell.textLabel.text = NSLocalizedString(@"Privacy", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuPrivacy"];
            break;
        case PGSideBarMenuCellAbout:
            cell.textLabel.text = NSLocalizedString(@"About", nil);
            cell.imageView.image = [UIImage imageNamed:@"menuAbout"];
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kPGSideBarMenuNumberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((PGSideBarMenuCellTakeSurvey == indexPath.row)  &&  ![NSLocale isSurveyAvailable]) {
        return 0.0F;
    } else if (IS_IPHONE_4) {
        return kPGSideBarMenuSmallCellHeight;
    }
    
    return kPGSideBarMenuRegularCellHeight;
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

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
