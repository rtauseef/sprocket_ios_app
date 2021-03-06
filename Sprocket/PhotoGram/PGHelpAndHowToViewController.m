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

#import "PGHelpAndHowToViewController.h"
#import "UIViewController+Trackable.h"
#import "PGWebViewerViewController.h"
#import "PGAnalyticsManager.h"
#import "NSLocale+Additions.h"

#import <Social/Social.h>
#import <MP.h>

typedef NS_ENUM(NSInteger, PGHelpAndHowToRowIndexes) {
    PGHelpAndHowToRowIndexesResetPrinter,
    PGHelpAndHowToRowIndexesSetupPrinter,
    PGHelpAndHowToRowIndexesViewUserGuide,
    PGHelpAndHowToRowIndexesMessengerSupport,
    PGHelpAndHowToRowIndexesTweetSupport,
    PGHelpAndHowToRowIndexesWeChatSupport,
    PGHelpAndHowToRowIndexesJoinSupport,
    PGHelpAndHowToRowIndexesVisitSupport,
    PGHelpAndHowToRowIndexesGiveFeedback
};

NSString * const kHelpLinksActionViewUserGuide = @"View User Guide";
NSString * const kHelpLinksActionJoinSupportForum = @"Join Support Forum";
NSString * const kHelpLinksActionVisitSupportWebsite = @"Visit Support Website";
NSString * const kHelpLinksActionMessengerSupport = @"Messenger Support";
NSString * const kHelpLinksActionWeChatSupport = @"WeChat Support";
NSString * const kHelpLinksActionTweetSupport = @"Tweet Support";

static NSString * const kPGHelpAndHowToWeChatSupportURL = @"http://mp.weixin.qq.com/s/xpbdBP6DlevbVt6j_redWQ";

@interface PGHelpAndHowToViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *tweetSupportCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *resetPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *setupPrinterCell;
@property (strong, nonatomic) SLComposeViewController *twitterComposeViewController;
@property (weak, nonatomic) IBOutlet UITableViewCell *giveFeedbackCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *messengerSupportCell;

@end

@implementation PGHelpAndHowToViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Help and How To Screen";

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unselectTableViewCell)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    UIImage *arrowMenuImage = [UIImage imageNamed:@"arrowMenu"];
    self.resetPrinterCell.accessoryView = [[UIImageView alloc] initWithImage:arrowMenuImage];
    self.setupPrinterCell.accessoryView = [[UIImageView alloc] initWithImage:arrowMenuImage];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)doneButtonTapped:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)unselectTableViewCell
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)dismissPresentedViewController:(UIStoryboardSegue *)segue
{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case PGHelpAndHowToRowIndexesViewUserGuide:
            [[PGAnalyticsManager sharedManager] trackHelpLinksActivity:kHelpLinksActionViewUserGuide];
            [[UIApplication sharedApplication] openURL:[NSLocale userGuideURL]];
            break;
            
        case PGHelpAndHowToRowIndexesMessengerSupport:
            [[PGAnalyticsManager sharedManager] trackHelpLinksActivity:kHelpLinksActionMessengerSupport];
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:[NSLocale messengerSupportURL]]];
            break;

        case PGHelpAndHowToRowIndexesTweetSupport:
            [[PGAnalyticsManager sharedManager] trackHelpLinksActivity:kHelpLinksActionTweetSupport];
            [self tweetSupportModal:indexPath];
            break;

        case PGHelpAndHowToRowIndexesWeChatSupport:
            [[PGAnalyticsManager sharedManager] trackHelpLinksActivity:kHelpLinksActionWeChatSupport];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPGHelpAndHowToWeChatSupportURL]];
            break;

        case PGHelpAndHowToRowIndexesJoinSupport:
            [[PGAnalyticsManager sharedManager] trackHelpLinksActivity:kHelpLinksActionJoinSupportForum];
            [[UIApplication sharedApplication] openURL:[NSLocale supportForumURL]];
            break;

        case PGHelpAndHowToRowIndexesVisitSupport:
            [[PGAnalyticsManager sharedManager] trackHelpLinksActivity:kHelpLinksActionVisitSupportWebsite];
            [[UIApplication sharedApplication] openURL:[NSLocale supportWebsiteURL]];
            break;

        case PGHelpAndHowToRowIndexesGiveFeedback: {
            [self sendEmail];
            break;
        }

        default:
            break;
    }
}

- (void)tweetSupportModal:(NSIndexPath *)indexPath
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *fwVersion = nil;
    NSString *tweetText = nil;
    NSString *tweetStringURL = nil;
    NSString *enterTextURL = NSLocalizedString(@"Enter+Text", nil);
    NSString *enterText = NSLocalizedString(@"Enter Text", nil);
    NSString *supportTagURL = [NSLocale twitterSupportTagURL];
    NSString *supportTag = [NSLocale twitterSupportTag];
    
    tweetText = [NSString stringWithFormat:@"%@ #hpsprocket \nS: %@ \n[%@]", supportTag, appVersion, enterText];
    tweetStringURL = [NSString stringWithFormat:@"http://twitter.com/intent/tweet?text=%@+%%23hpsprocket%%0aS:%@+%%0a%%5B%@%%5D", supportTagURL, appVersion, [enterTextURL stringByAddingPercentEscapesUsingEncoding : NSUTF8StringEncoding]];

    if (IS_OS_8_OR_LATER) {
        NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
        
        if (numberOfPairedSprockets == 1) {
            fwVersion = [[MP sharedInstance] printerVersion];
            tweetText = [NSString stringWithFormat:@"%@ #hpsprocket \nS:%@ F:%@ \n[%@]", supportTag, appVersion, fwVersion, enterText];
            tweetStringURL = [NSString stringWithFormat:@"http://twitter.com/intent/tweet?text=%@+%%23hpsprocket%%0aS:%@+F:%@+%%0a%%5B%@%%5D", supportTagURL, appVersion, fwVersion, enterTextURL];
        }
    }
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        self.twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self.twitterComposeViewController addImage:[UIImage imageNamed:@"Support_Printers.jpg"]];
        [self.twitterComposeViewController setInitialText:tweetText];
        
        __weak typeof(self) weakSelf = self;
        [self.twitterComposeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultCancelled) {
                [weakSelf.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:YES];
            } else {
                NSURL *urlApp = [NSURL URLWithString:@"twitter://"];
                
                if ([[UIApplication sharedApplication] canOpenURL:urlApp]){
                    [[UIApplication sharedApplication] openURL:urlApp];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/"]];
                }
                
                [weakSelf.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:YES];
            }
        }];
        
        [self presentViewController:self.twitterComposeViewController animated:YES completion:nil];
    } else {
        if ([NSLocale twitterHPCareSupportURL].length != 0) {
            tweetStringURL = [NSLocale twitterHPCareSupportURL];
        }
        NSURL *tweetURL = [NSURL URLWithString:tweetStringURL];
        [[UIApplication sharedApplication] openURL:tweetURL];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![NSLocale isTwitterSupportAvailable] && indexPath.row == PGHelpAndHowToRowIndexesTweetSupport) {
        return 0;
    }

    if (![NSLocale isChinese] && indexPath.row == PGHelpAndHowToRowIndexesWeChatSupport) {
        return 0;
    }
    
    if (![NSLocale isFBMessengerSupportAvailable] && indexPath.row == PGHelpAndHowToRowIndexesMessengerSupport) {
        return 0;
    }

    return tableView.rowHeight;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
