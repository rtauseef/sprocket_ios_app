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
    PGHelpAndHowToRowIndexesTweetSupport,
    PGHelpAndHowToRowIndexesWeChatSupport,
    PGHelpAndHowToRowIndexesJoinSupport,
    PGHelpAndHowToRowIndexesVisitSupport
};

NSString * const kViewUserGuideScreenName = @"View User Guide";
NSString * const kVisitWebsiteScreenName = @"Visit Website";
NSString * const kJoinForumScreenName = @"Join Forum Screen";

static NSString * const kPGHelpAndHowToWeChatSupportURL = @"http://mp.weixin.qq.com/s/xpbdBP6DlevbVt6j_redWQ";

@interface PGHelpAndHowToViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *tweetSupportCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *resetPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *setupPrinterCell;
@property (strong, nonatomic) SLComposeViewController *twitterComposeViewController;

@end

@implementation PGHelpAndHowToViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Help and How To Screen";
    
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
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kViewUserGuideScreenName];
            [[UIApplication sharedApplication] openURL:[NSLocale userGuideURL]];
            break;

        case PGHelpAndHowToRowIndexesTweetSupport:
            [self tweetSupportModal:indexPath];
            break;

        case PGHelpAndHowToRowIndexesWeChatSupport:
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kJoinForumScreenName];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPGHelpAndHowToWeChatSupportURL]];
            break;

        case PGHelpAndHowToRowIndexesJoinSupport:
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kJoinForumScreenName];
            [[UIApplication sharedApplication] openURL:[NSLocale supportForumURL]];
            break;

        case PGHelpAndHowToRowIndexesVisitSupport:
            [[PGAnalyticsManager sharedManager] trackScreenViewEvent:kVisitWebsiteScreenName];
            [[UIApplication sharedApplication] openURL:[NSLocale supportWebsiteURL]];
            break;

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
    tweetStringURL = [NSString stringWithFormat:@"http://twitter.com/intent/tweet?text=%@+%%23hpsprocket%%0aS:%@+%%0a%%5B%@%%5D", supportTagURL, appVersion, enterTextURL];
    
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
        NSURL *tweetURL = [NSURL URLWithString:tweetStringURL];
        [[UIApplication sharedApplication] openURL:tweetURL];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NSLocale isChinese] && indexPath.row == PGHelpAndHowToRowIndexesTweetSupport) {
        return 0;
    }

    if (![NSLocale isChinese] && indexPath.row == PGHelpAndHowToRowIndexesWeChatSupport) {
        return 0;
    }

    return tableView.rowHeight;
}

@end
