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

#import <Social/Social.h>
#import <MP.h>

typedef NS_ENUM(NSInteger, PGHelpAndHowToRowIndexes) {
    PGHelpAndHowToRowIndexesViewUserGuide,
    PGHelpAndHowToRowIndexesTweetSupport,
    PGHelpAndHowToRowIndexesJoinSupport,
    PGHelpAndHowToRowIndexesVisitSupport
};

NSString * const kPGHelpAndHowToViewUserURL = @" http://h10032.www1.hp.com/ctg/Manual/c05280005";
NSString * const kPGHelpAndHowToVisitWebsiteURL = @"http://support.hp.com/us-en/product/HP-Sprocket-Photo-Printer/12635221";
NSString * const kPGHelpAndHowToJoinForumSupportURL = @"http://hp.care/sprocket";

@interface PGHelpAndHowToViewController ()

@property (strong, nonatomic) IBOutlet UITableViewCell *tweetSupportCell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case PGHelpAndHowToRowIndexesViewUserGuide: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPGHelpAndHowToViewUserURL]];
            break;
        }
        case PGHelpAndHowToRowIndexesTweetSupport: {
            [self tweetSupportModal:indexPath];
            break;
        }
        case PGHelpAndHowToRowIndexesJoinSupport: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPGHelpAndHowToJoinForumSupportURL]];
            break;
        }
        case PGHelpAndHowToRowIndexesVisitSupport: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPGHelpAndHowToVisitWebsiteURL]];
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
    
    tweetText = [NSString stringWithFormat:@"@hpsupport #hpsprocket \nS: %@ \n[%@]", appVersion, enterText];
    tweetStringURL = [NSString stringWithFormat:@"http://twitter.com/intent/tweet?text=@hpsupport+%%23hpsprocket%%0aS:%@+%%0a%%5B%@%%5D", appVersion, enterTextURL];
    
    
    
    if (IS_OS_8_OR_LATER) {
        NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
        
        if (numberOfPairedSprockets == 1) {
            fwVersion = [[MP sharedInstance] printerVersion];
            tweetText = [NSString stringWithFormat:@"@hpsupport #hpsprocket \nS:%@ F:%@ \n[%@]", appVersion, fwVersion, enterText];
            tweetStringURL = [NSString stringWithFormat:@"http://twitter.com/intent/tweet?text=@hpsupport+%%23hpsprocket%%0aS:%@+F:%@+%%0a%%5B%@%%5D", appVersion, fwVersion, enterTextURL];
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

@end
