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

#define LONG_SCREEN_SIZE_HEADER_HEIGHT 75.0f
#define SHORT_SCREEN_SIZE_HEADER_HEIGHT 52.0f

#define CELL_HEIGHT 52.0f
#define CELL_HEIGHT_SMALL 42.0f
#define CELL_SOCIAL_HEIGHT_SMALL 40.0f

#define DEVICE_CONNECTIVITY_LABEL_X 58.0f
#define SIGN_OUT_SPACE 1.0f

#define DEVICES_INDEX 0
#define BUY_PAPER 1
#define HOW_TO_HELP 2
#define GIVE_FEEDBACK 3
#define PRIVACY_STATEMENT_INDEX 4
#define ABOUT_INDEX 5

#define kSignInButtonTitle NSLocalizedString(@"Sign In", nil)
#define kSignOutButtonTitle NSLocalizedString(@"Sign Out", nil)
#define kCheckingButtonTitle NSLocalizedString(@"Checking", @"Checking the login status of the social network")

NSString * const kPrivacyStatementURL = @"http://www8.hp.com/%@/%@/privacy/privacy.html";
NSString * const kTakeOurSurveyURL = @"https://www.surveymonkey.com/s/9C9M96H";
NSString * const kTakeOurSurveyNotifyURL = @"www.surveymonkey.com/r/close-window";
NSString * const kBuyPaperURL = @"http://hpsprocket.com/#supplies";

NSString * const kSocialNetworkKey = @"social-network";
NSString * const kIncludeLoginKey = @"include-login";

@interface PGSideBarMenuTableViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, PGWebViewerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

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

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *socialSourcesCellHeight;
@property (weak, nonatomic) IBOutlet UIView *cameraRollView;

@property (assign, nonatomic, getter = isFlickrLogged) BOOL flickrLogged;
@property (assign, nonatomic, getter = isFacebookLogged) BOOL facebookLogged;
@property (assign, nonatomic, getter = isInstagramLogged) BOOL instagramLogged;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;
@property (weak, nonatomic) IBOutlet UITableViewCell *devicesCell;

@property (weak, nonatomic) IBOutlet UILabel *deviceConnectivityLabel;
@property (strong, nonatomic) IBOutlet UIView *deviceStatusLED;
@property (strong, nonatomic) IBOutlet UILabel *devicesLabel;

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

    NSMutableArray *cells = [NSMutableArray arrayWithArray:self.cells];
    [cells addObject:self.devicesCell];
    
    self.cells = cells.copy;
    
    self.trackableScreenName = @"Side Bar Menu Screen";
    
    self.tableView.scrollEnabled = NO;
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    
    CGRect headerFrame = self.tableView.tableHeaderView.frame;
    if (IS_IPHONE_4) {
        headerFrame.size.height = SHORT_SCREEN_SIZE_HEADER_HEIGHT;
    } else {
        headerFrame.size.height = LONG_SCREEN_SIZE_HEADER_HEIGHT;
    }
    
    self.tableView.tableHeaderView.frame = headerFrame;
    [self.view layoutIfNeeded];
    
    UIView *gradientBackgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    [PGAppAppearance addGradientBackgroundToView:gradientBackgroundView];
    self.tableView.backgroundView = gradientBackgroundView;
    
    UIView *selectionColorView = [[UIView alloc] init];
    selectionColorView.backgroundColor = [UIColor HPTableRowSelectionColor];
    
    for (UITableViewCell *cell in self.cells) {
        if (cell.textLabel) {
            [self setupLabel:cell.textLabel];
        }
        
        [cell setSelectedBackgroundView:selectionColorView];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    [self setupSocialItemView:self.instagramUserView];
    [self setupSocialItemView:self.facebookUserView];
    [self setupSocialItemView:self.flickrUserView];
    [self setupSocialItemView:self.cameraRollView];
    
    if (IS_IPHONE_4) {
        self.socialSourcesCellHeight.constant = CELL_SOCIAL_HEIGHT_SMALL;
    }
    
    [self.view layoutIfNeeded];
    
    [self.instagramSignButton setTitle:kCheckingButtonTitle forState:UIControlStateNormal];
    self.instagramSignButton.userInteractionEnabled = NO;
    self.instagramGestureRecognizer.enabled = NO;
    
    [self.facebookSignButton setTitle:kCheckingButtonTitle forState:UIControlStateNormal];
    self.facebookSignButton.userInteractionEnabled = NO;
    self.facebookGestureRecognizer.enabled = NO;
    
    [self.flickrSignButton setTitle:kCheckingButtonTitle forState:UIControlStateNormal];
    self.flickrSignButton.userInteractionEnabled = NO;
    self.flickrGestureRecognizer.enabled = NO;
    

    
    [self setupLabel:self.deviceConnectivityLabel];
    self.deviceConnectivityLabel.font = [UIFont HPSimplifiedLightFontWithSize:12.0f];
    
    [self setupLabel:self.devicesLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unselectTableViewCell)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self setInstagramUserView];
    [self setFacebookUserView];
    [self setFlickrUserView];
    [self setTableFooterHeight];
    
    if (IS_OS_8_OR_LATER) {
        NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
        if (numberOfPairedSprockets > 0) {
            self.deviceConnectivityLabel.hidden = NO;
            self.deviceStatusLED.hidden = NO;
        } else {
            self.deviceConnectivityLabel.hidden = YES;
            self.deviceStatusLED.hidden = YES;
        }
    }
    
    // Resizing the table to the width revealed by the SWRevealViewController forces word-wrapping where necessary
    CGRect frame = self.tableView.frame;
    frame.size.width = self.revealViewController.rearViewRevealWidth;
    self.tableView.frame = frame;
}

- (void)unselectTableViewCell
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
    if (IS_IPHONE_4) {
        return CELL_HEIGHT_SMALL;
    }
    
    return CELL_HEIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case GIVE_FEEDBACK: {
            [self sendEmail];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        case DEVICES_INDEX: {
            [[MP sharedInstance] presentBluetoothDevicesFromController:self.revealViewController animated:YES completion:nil];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
        case BUY_PAPER: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kBuyPaperURL]];
            break;
        }
        case PRIVACY_STATEMENT_INDEX: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:kPrivacyStatementURL, [NSLocale countryID], [NSLocale languageID]]]];
            break;
        }
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Button action

- (void)barButtonCancelPressed:(id)sender
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

- (void)setupLabel:(UILabel *)label
{
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont HPSimplifiedLightFontWithSize:17.0f];
}

- (void)setupSocialItemView:(UIView *)view
{
    view.backgroundColor = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRBackgroundColor];
}

- (void)setTableFooterHeight
{
    CGFloat tableHeight;
    CGFloat cellHeight;
    
    if (IS_PORTRAIT) {
        tableHeight = [[UIScreen mainScreen] bounds].size.height;
    } else {
        tableHeight = [[UIScreen mainScreen] bounds].size.width;
    }
    
    if (IS_IPHONE_4) {
        cellHeight = CELL_HEIGHT_SMALL;
    } else {
        cellHeight = CELL_HEIGHT;
    }
    
    CGRect footerFrame = self.tableView.tableFooterView.frame;
    
    footerFrame.size.height = tableHeight  - (self.tableView.tableHeaderView.frame.size.height + self.cells.count * cellHeight);

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
