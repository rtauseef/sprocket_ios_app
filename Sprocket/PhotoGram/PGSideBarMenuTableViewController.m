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

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <HPPR.h>
#import <MP.h>
#import <HPPRInstagramUser.h>
#import <HPPRInstagram.h>

#import <HPPRInstagramPhotoProvider.h>
#import <HPPRFacebookPhotoProvider.h>
#import <HPPRFlickrPhotoProvider.h>
#import <HPPRCameraRollPhotoProvider.h>

#import <HPPRFacebookLoginProvider.h>
#import <HPPRInstagramLoginProvider.h>
#import <HPPRFlickrLoginProvider.h>

#import "PGSideBarMenuTableViewController.h"
#import "PGRevealViewController.h"
#import "PGSurveyManager.h"
#import "PGAppAppearance.h"
#import "UIFont+Style.h"
#import "UIColor+Style.h"
#import "PGAppDelegate.h"
#import "UIImageView+MaskImage.h"
#import "PGWebViewerViewController.h"
#import "UIViewController+Trackable.h"
#import "NSLocale+Additions.h"

#define LONG_SCREEN_SIZE_HEADER_HEIGHT 140.0f
#define SHORT_SCREEN_SIZE_HEADER_HEIGHT 70.0f
#define SHORT_SCREEN_SIZE_TITLE_LABEL_Y_POSITION 31.0f

#define PRINT_LATER_NUMBER_OF_JOBS_LABEL_X 58.0f
#define SIGN_OUT_SPACE 1.0f
#define CELL_HEIGHT 44.0f
#define TRANSPARENT_CELL_HEIGHT 10.0f

#define SOCIAL_NETWORK_SEPARATOR_HEIGHT 1.0f

#define PRINT_QUEUE_INDEX 0
#define TRANSPARENT_PRINT_QUEUE_INDEX 1
#define LEARN_ABOUT_MOBILE_PRINTING_INDEX 2
#define ABOUT_INDEX 4
#define SEND_FEEDBACK_INDEX 6
#define TAKE_OUR_SURVEY_INDEX 8
#define TAKE_OUR_SURVEY_TRANSPARENT_INDEX 9
#define PRIVACY_STATEMENT_INDEX 10

#define kSignInButtonTitle NSLocalizedString(@"Sign In", nil)
#define kSignOutButtonTitle NSLocalizedString(@"Sign Out", nil)
#define kCheckingButtonTitle NSLocalizedString(@"Checking", @"Checking the login status of the social network")

NSString * const kPrivacyStatementURL = @"http://www8.hp.com/%@/%@/privacy/privacy.html";
//NSString * const kPrivacyStatementURL = @"http://www8.hp.com/us/%@/privacy/privacy.html";
NSString * const kTakeOurSurveyURL = @"https://www.surveymonkey.com/s/9C9M96H";
NSString * const kTakeOurSurveyNotifyURL = @"www.surveymonkey.com/r/close-window";

NSString * const kSocialNetworkKey = @"social-network";
NSString * const kIncludeLoginKey = @"include-login";

NSInteger const kSideBarRightSideBufferWidth = 40; //pixels

@interface PGSideBarMenuTableViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, PGWebViewerViewControllerDelegate>

@property (assign, nonatomic) BOOL longHeaderFits;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopSpaceLayoutContraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flickrBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *flickrUserView;
@property (weak, nonatomic) IBOutlet UILabel *flickrUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *flickrSignButton;
@property (weak, nonatomic) IBOutlet UIImageView *flickrUserImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *facebookUserView;
@property (weak, nonatomic) IBOutlet UILabel *facebookUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookSignButton;
@property (weak, nonatomic) IBOutlet UIImageView *facebookUserImageView;

@property (weak, nonatomic) IBOutlet UIView *instagramUserView;
@property (weak, nonatomic) IBOutlet UILabel *instagramUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *instagramSignButton;
@property (weak, nonatomic) IBOutlet UIImageView *instagramUserImageView;

@property (weak, nonatomic) IBOutlet UIView *cameraRollView;

@property (assign, nonatomic, getter = isFlickrLogged) BOOL flickrLogged;
@property (assign, nonatomic, getter = isFacebookLogged) BOOL facebookLogged;
@property (assign, nonatomic, getter = isInstagramLogged) BOOL instagramLogged;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *transparentCells;
@property (weak, nonatomic) IBOutlet UITableViewCell *printLaterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printLaterTransparentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *takeOurSurveyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *takeOurSurveyTransparentCell;
@property (weak, nonatomic) IBOutlet UILabel *printLaterNumberOfJobsLabel;

@property (weak, nonatomic) IBOutlet UILabel *printQueueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *printLaterNumberOfJobsLabelLeadingLayoutConstraint;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *instagramGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *facebookGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *flickrGestureRecognizer;

typedef enum {
    Instagram,
    Facebook,
    Flickr
} SocialMediaProviders;

@end

@implementation PGSideBarMenuTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
    UIColor *navBarColor = [PGAppAppearance navBarColor];

    NSMutableArray *cells = [NSMutableArray arrayWithArray:self.cells];
    NSMutableArray *transparentCells = [NSMutableArray arrayWithArray:self.transparentCells];
    
    if (IS_OS_8_OR_LATER) {
        [cells addObject:self.printLaterCell];
        [transparentCells addObject:self.printLaterTransparentCell];
        
        if ([NSLocale isSurveyAvailable] && !IS_IPHONE_4) {
            [cells addObject:self.takeOurSurveyCell];
            [transparentCells addObject:self.takeOurSurveyTransparentCell];
        }
        
        [self setupLabel:self.printLaterNumberOfJobsLabel];
        
        self.printLaterNumberOfJobsLabel.backgroundColor = navBarColor;
        self.printLaterNumberOfJobsLabel.layer.cornerRadius = (self.printLaterNumberOfJobsLabel.frame.size.width / 2);
        self.printLaterNumberOfJobsLabel.layer.masksToBounds = YES;
        
        [self positionPrintLaterNumberOfJobsLabelBasedOnLocalization];
        
    } else {
        if ([NSLocale isSurveyAvailable]) {
            [cells addObject:self.takeOurSurveyCell];
            [transparentCells addObject:self.takeOurSurveyTransparentCell];
        }
    }
    
    self.cells = cells.copy;
    self.transparentCells = transparentCells.copy;
    
    
    CGFloat heightWithoutHeader = (self.cells.count * CELL_HEIGHT) + (self.transparentCells.count * TRANSPARENT_CELL_HEIGHT) + [self statusBarHeight] + self.instagramUserView.frame.size.height + SOCIAL_NETWORK_SEPARATOR_HEIGHT + self.facebookUserView.frame.size.height + SOCIAL_NETWORK_SEPARATOR_HEIGHT + self.flickrUserView.frame.size.height + SOCIAL_NETWORK_SEPARATOR_HEIGHT + self.cameraRollView.frame.size.height;
    
    
    if (([[UIScreen mainScreen] bounds].size.height - heightWithoutHeader) > LONG_SCREEN_SIZE_HEADER_HEIGHT) {
        self.longHeaderFits = YES;
    } else {
        self.longHeaderFits = NO;
    }
    
    if (!self.longHeaderFits) {
        CGRect tableViewHeaderFrame = self.tableView.tableHeaderView.frame;
        tableViewHeaderFrame.size.height = SHORT_SCREEN_SIZE_HEADER_HEIGHT;
        self.tableView.tableHeaderView.frame = tableViewHeaderFrame;
        
        self.logoImageView.hidden = YES;
        
        self.titleLabelTopSpaceLayoutContraint.constant = SHORT_SCREEN_SIZE_TITLE_LABEL_Y_POSITION;
    }
    
    self.tableView.scrollEnabled = NO;
    
    self.trackableScreenName = @"Side Bar Menu Screen";
    
    self.tableView.tableHeaderView.backgroundColor = navBarColor;
    self.tableView.tableFooterView.backgroundColor = navBarColor;
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    
    for (UITableViewCell *cell in self.cells) {
        [self setupLabel:cell.textLabel];
        [cell setSelectedBackgroundView:selectionColorView];
        cell.backgroundColor = navBarColor;
    }
    
    for (UITableViewCell *transparentCell in self.transparentCells) {
        transparentCell.backgroundColor = navBarColor;
    }
    
    self.tableView.tableFooterView.backgroundColor = navBarColor;
    self.instagramUserView.backgroundColor = backgroundColor;
    self.facebookUserView.backgroundColor = backgroundColor;
    self.flickrUserView.backgroundColor = backgroundColor;
    self.cameraRollView.backgroundColor = backgroundColor;
    
    [self.instagramSignButton setTitle:kCheckingButtonTitle forState:UIControlStateNormal];
    self.instagramSignButton.userInteractionEnabled = NO;
    self.instagramGestureRecognizer.enabled = NO;
    
    [self.facebookSignButton setTitle:kCheckingButtonTitle forState:UIControlStateNormal];
    self.facebookSignButton.userInteractionEnabled = NO;
    self.facebookGestureRecognizer.enabled = NO;
    
    [self.flickrSignButton setTitle:kCheckingButtonTitle forState:UIControlStateNormal];
    self.flickrSignButton.userInteractionEnabled = NO;
    self.flickrGestureRecognizer.enabled = NO;
}

- (void)positionPrintLaterNumberOfJobsLabelBasedOnLocalization
{
    CGSize size = [self.printQueueLabel.text sizeWithAttributes:@{NSFontAttributeName: self.printLaterNumberOfJobsLabel.font}];
    
    self.printLaterNumberOfJobsLabelLeadingLayoutConstraint.constant = PRINT_LATER_NUMBER_OF_JOBS_LABEL_X + size.width  + 10;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setInstagramUserView];
    [self setFacebookUserView];
    [self setFlickrUserView];
    [self setTableFooterHeight];
    
    if (IS_OS_8_OR_LATER) {
        NSInteger numberOfPrintJobs = [[MP sharedInstance] numberOfJobsInQueue];
        if (numberOfPrintJobs > 0) {
            self.printLaterNumberOfJobsLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfPrintJobs];
            self.printLaterNumberOfJobsLabel.hidden = NO;
        } else {
            self.printLaterNumberOfJobsLabel.hidden = YES;
        }
    }
    
    // Resizing the table to the width revealed by the SWRevealViewController forces word-wrapping where necessary
    CGRect frame = self.tableView.frame;
    frame.size.width = self.revealViewController.rearViewRevealWidth;
    self.tableView.frame = frame;
}

#pragma mark - Setter methods

- (void)setFlickrLogged:(BOOL)flickrLogged
{
    _flickrLogged = flickrLogged;
    NSString *title = (flickrLogged) ? kSignOutButtonTitle : kSignInButtonTitle;
    [self.flickrSignButton setTitle:title forState:UIControlStateNormal];
    self.flickrSignButton.userInteractionEnabled = YES;
    self.flickrGestureRecognizer.enabled = YES;
}

- (void)setFacebookLogged:(BOOL)facebookLogged
{
    _facebookLogged = facebookLogged;
    NSString *title = (facebookLogged) ? kSignOutButtonTitle : kSignInButtonTitle;
    [self.facebookSignButton setTitle:title forState:UIControlStateNormal];
    self.facebookSignButton.userInteractionEnabled = YES;
    self.facebookGestureRecognizer.enabled = YES;
}

- (void)setInstagramLogged:(BOOL)instagramLogged
{
    _instagramLogged = instagramLogged;
    NSString *title = (instagramLogged) ? kSignOutButtonTitle : kSignInButtonTitle;
    [self.instagramSignButton setTitle:title forState:UIControlStateNormal];
    self.instagramSignButton.userInteractionEnabled = YES;
    self.instagramGestureRecognizer.enabled = YES;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Hide Take our survey for languages other than English (because the survey is not localized)
    if (![NSLocale isSurveyAvailable] && ((indexPath.row == TAKE_OUR_SURVEY_INDEX) || (indexPath.row == TAKE_OUR_SURVEY_TRANSPARENT_INDEX))) {
        return 0.0f;
    }
    
    if (!IS_OS_8_OR_LATER && ((indexPath.row == PRINT_QUEUE_INDEX) || (indexPath.row == TRANSPARENT_PRINT_QUEUE_INDEX))) {
        return 0.0f;
    } else if (IS_OS_8_OR_LATER && IS_IPHONE_4 && ((indexPath.row == TAKE_OUR_SURVEY_INDEX) || (indexPath.row == TAKE_OUR_SURVEY_TRANSPARENT_INDEX))) {
        return 0.0f;
    } else if ([self isTransparentCell:indexPath.row]) {
        if (!self.longHeaderFits) {
            return 0.0f;
        } else {
            return TRANSPARENT_CELL_HEIGHT;
        }
    } else {
        return CELL_HEIGHT;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == SEND_FEEDBACK_INDEX) {
        [self sendEmail];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.row == PRINT_QUEUE_INDEX) {
        [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PrivacyStatementSegue"]) {
        UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
        
        PGWebViewerViewController *webViewerViewController = (PGWebViewerViewController *)navigationController.topViewController;
        webViewerViewController.trackableScreenName = @"Privacy Statement Screen";
        NSString *localizablePrivacyStatementURL = [NSString stringWithFormat:kPrivacyStatementURL, [NSLocale countryID], [NSLocale languageID]];
        
        webViewerViewController.url = localizablePrivacyStatementURL;
        
    } else if ([segue.identifier isEqualToString:@"TakeOurSurveySegue"]) {
        UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
        
        PGWebViewerViewController *webViewerViewController = (PGWebViewerViewController *)navigationController.topViewController;
        webViewerViewController.trackableScreenName = @"Take Our Survey Screen";
        webViewerViewController.url = kTakeOurSurveyURL;
        webViewerViewController.notifyUrl = kTakeOurSurveyNotifyURL;
        webViewerViewController.delegate = self;
    }
}

#pragma mark - Button action

-(void)barButtonCancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)flickrSignButtonTapped:(id)sender
{
    if (self.isFlickrLogged) {
        [self displaySignOutAlert:[HPPRFlickrPhotoProvider sharedInstance].name alertTag:Flickr];
    } else {
        [self showSocialNetwork:[HPPRFlickrPhotoProvider sharedInstance].name includeLogin:YES];
    }
}

- (IBAction)facebookSignButtonTapped:(id)sender
{
    if (self.isFacebookLogged) {
        [self displaySignOutAlert:[HPPRFacebookPhotoProvider sharedInstance].name alertTag:Facebook];
    } else {
        [self showSocialNetwork:[HPPRFacebookPhotoProvider sharedInstance].name includeLogin:YES];
    }
}

- (IBAction)instagramSignButtonTapped:(id)sender
{
    if (self.isInstagramLogged) {
        [self displaySignOutAlert:[HPPRInstagramPhotoProvider sharedInstance].name alertTag:Instagram];
    } else {
        [self showSocialNetwork:[HPPRInstagramPhotoProvider sharedInstance].name includeLogin:YES];
    }
}

#pragma mark - Sign Out UIAlertView

- (void)displaySignOutAlert:(NSString *)providerName alertTag:(SocialMediaProviders)alertTag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *alertMessage = [NSString localizedStringWithFormat:
                                  NSLocalizedString(@"Would you like to sign out of %@?",
                                                    @"Ask user if he/she wishes to sign out of a particular social media site."), providerName];
        NSString *cancel = [NSString localizedStringWithFormat:
                            NSLocalizedString(@"Cancel",
                                              @"Generic Cancel from an action.")];
        NSString *signOut = [NSString localizedStringWithFormat:
                             NSLocalizedString(@"Sign Out",
                                               @"Signing out of a social media site.")];
        if (IS_OS_8_OR_LATER) {
            __block SocialMediaProviders alertTagForLater = alertTag;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:alertMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:signOut style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self signOut:alertTagForLater];
                                                                  }];
            
            [alert addAction:cancelAction];
            [alert addAction:signOutAction];
            
            // Setting the preferred action is only available in iOS9 and later
            if ([alert respondsToSelector:@selector(setPreferredAction:)]) {
                [alert performSelector:@selector(setPreferredAction:) withObject:cancelAction];
            }
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:cancel
                                                  otherButtonTitles:signOut, nil];
            alert.tag = alertTag;
            [alert show];
        }
    });
}

#pragma mark - Sign Out UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self signOut:(SocialMediaProviders)alertView.tag];
}

- (void)signOut:(SocialMediaProviders)providerTag
{
    HPPRLoginProvider *provider = nil;
    NSString *socialNetworkName = nil;
    
    switch (providerTag) {
        case Flickr:
            provider = [HPPRFlickrLoginProvider sharedInstance];
            socialNetworkName = [HPPRFlickrPhotoProvider sharedInstance].name;
            break;
            
        case Facebook:
            provider = [HPPRFacebookLoginProvider sharedInstance];
            socialNetworkName = [HPPRFacebookPhotoProvider sharedInstance].name;
            break;
            
        case Instagram:
            provider = [HPPRInstagramLoginProvider sharedInstance];
            socialNetworkName = [HPPRInstagramPhotoProvider sharedInstance].name;
            break;
            
        default:
            break;
    }
    
    [self signOut:provider socialNetwork:socialNetworkName];
}

#pragma mark - Utils

- (BOOL)isTransparentCell:(NSInteger)cellIndex
{
    return (cellIndex% 2 != 0);
}

- (void)setupLabel:(UILabel *)label
{
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont HPSimplifiedRegularFontWithSize:14.0f];
}

- (void)setTableFooterHeight
{
    CGFloat tableHeight;
    
    if (IS_OS_8_OR_LATER) {
        tableHeight = [[UIScreen mainScreen] bounds].size.height;
    } else {
        if (IS_PORTRAIT) {
            tableHeight = [[UIScreen mainScreen] bounds].size.height;
        }else {
            tableHeight = [[UIScreen mainScreen] bounds].size.width;
        }
    }
    
    CGRect footerFrame = self.tableView.tableFooterView.frame;
    footerFrame.size.height = tableHeight  - (self.tableView.tableHeaderView.frame.size.height + self.cells.count * CELL_HEIGHT);
    if (self.longHeaderFits) {
        footerFrame.size.height = footerFrame.size.height - (self.transparentCells.count * TRANSPARENT_CELL_HEIGHT);
    }
    self.tableView.tableFooterView.frame = footerFrame;
}

- (void)setInstagramUserView
{
    [HPPRInstagramUser userProfileWithId:@"self" completion:^(NSString *userName, NSString *userId, NSString *profilePictureUrl, NSNumber *posts, NSNumber *followers, NSNumber *following) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (profilePictureUrl) {
                [self.instagramUserImageView setMaskImageWithURL:profilePictureUrl];
                self.instagramLogged = YES;
            } else {
                self.instagramUserImageView.image = [UIImage imageNamed:@"Instagram"];
                self.instagramLogged = NO;
            }
        });
        
    }];
}

- (void)setFacebookUserView
{
    [[HPPRFacebookLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            [self fetchFacebookData];
        } else {
            self.facebookUserImageView.image = [UIImage imageNamed:@"Facebook"];
            self.facebookLogged = NO;
        }
    }];
}

- (void)setFlickrUserView
{
    [[HPPRFlickrLoginProvider sharedInstance] checkStatusWithCompletion:^(BOOL loggedIn, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (loggedIn) {
                NSDictionary *user = [HPPRFlickrLoginProvider sharedInstance].user;
                [self.flickrUserImageView setMaskImageWithURL:[user objectForKey:@"imageURL"]];
                self.flickrLogged = YES;
            } else {
                self.flickrUserImageView.image = [UIImage imageNamed:@"Flickr"];
                self.flickrLogged = NO;
            }
        });
    }];
}

- (void)fetchFacebookData
{
    [[HPPRFacebookPhotoProvider sharedInstance] userInfoWithRefresh:NO andCompletion:^(NSDictionary *userInfo, NSError *error) {
        __weak PGSideBarMenuTableViewController * weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^ {
            if (error) {
                weakSelf.facebookLogged = NO;
                weakSelf.facebookUserImageView.image = [UIImage imageNamed:@"Facebook"];
            } else {
                NSString *profilePictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square",  [userInfo objectForKey:@"id"]];
                [weakSelf.facebookUserImageView setMaskImageWithURL:profilePictureUrl];
                weakSelf.facebookLogged = YES;
            }
        });
    }];
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

- (void)signOut:(HPPRLoginProvider *)provider socialNetwork:(NSString *)socialNetwork
{
    [provider logoutWithCompletion:^(BOOL loggedOut, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_PROVIDER_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:socialNetwork forKey:kSocialNetworkKey]];
            
            if ([socialNetwork isEqualToString:[HPPRInstagramPhotoProvider sharedInstance].name]) {
                [self setInstagramUserView];
            } else if ([socialNetwork isEqualToString:[HPPRFacebookPhotoProvider sharedInstance].name]) {
                [self setFacebookUserView];
            } else if ([socialNetwork isEqualToString:[HPPRFlickrPhotoProvider sharedInstance].name]) {
                [self setFlickrUserView];
            }
        });
    }];
}

- (void)showSocialNetwork:(NSString *)socialNetwork includeLogin:(BOOL)includeLogin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.revealViewController revealToggleAnimated:YES];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: socialNetwork, kSocialNetworkKey, [NSNumber numberWithBool:includeLogin], kIncludeLoginKey, nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SOCIAL_NETWORK_NOTIFICATION object:nil userInfo:userInfo];
    });
}

- (CGFloat)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

#pragma mark - Gesture recognizers

- (IBAction)cameraRollTapped:(id)sender
{
    [self showSocialNetwork:[HPPRCameraRollPhotoProvider sharedInstance].name includeLogin:NO];
}

- (IBAction)facebookTapped:(id)sender
{
    [self showSocialNetwork:[HPPRFacebookPhotoProvider sharedInstance].name includeLogin:(self.facebookLogged ? NO : YES)];
}

- (IBAction)instagramTapped:(id)sender
{
    [self showSocialNetwork:[HPPRInstagramPhotoProvider sharedInstance].name includeLogin:(self.instagramLogged ? NO : YES)];
}

- (IBAction)flickrTapped:(id)sender
{
    [self showSocialNetwork:[HPPRFlickrPhotoProvider sharedInstance].name includeLogin:(self.flickrLogged ? NO : YES)];
}

#pragma mark - PGWebViewerViewControllerDelegate methods

- (void)webViewerViewControllerDidReachNotifyUrl:(PGWebViewerViewController *)webViewerViewController
{
    [[PGSurveyManager sharedInstance] setDisable:YES];
    
    [webViewerViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
