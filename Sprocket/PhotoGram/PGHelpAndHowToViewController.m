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

NSString * const kPGHelpAndHowToViewUserURL = @"https://www.hpsprocket.com/sprocket-userguide.pdf";
NSString * const kPGHelpAndHowToVisitWebsiteURL = @"http://support.hp.com/us-en/products/printers/";
NSString * const kPGHelpAndHowToJoinForumSupportURL = @"http://h30434.www3.hp.com/t5/Printers/ct-p/InkJet";

@interface PGHelpAndHowToViewController ()

@property (strong, nonatomic) IBOutlet UITableViewCell *tweetSupportCell;
@property (strong, nonatomic) SLComposeViewController *twitterComposeViewController;

@end

@implementation PGHelpAndHowToViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"Help and How To Screen";
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *printerVersionString = nil;
        NSString *tweetText = nil;
        NSString *tweetStringURL = nil;
        NSString *enterTextURL = NSLocalizedString(@"Enter+Text", nil);
        NSString *enterText = NSLocalizedString(@"Enter Text", nil);
        
        tweetText = [NSString stringWithFormat:@"@hpsupport #hpsprocket \nS: %@ \n[%@]", appVersion, enterText];
        tweetStringURL = [NSString stringWithFormat:@"http://twitter.com/intent/tweet?text=@hpsupport+%%23hpsprocket%%0aS:%@+%%0a%%5B%@%%5D", appVersion, enterTextURL];
        
        
        
        if (IS_OS_8_OR_LATER) {
            NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
            
            if (numberOfPairedSprockets == 1) {
                NSUInteger printerVersion = [[MP sharedInstance] printerVersionNumber];
                NSUInteger fw1 = (0xFF0000 & printerVersion) >> 16;
                NSUInteger fw2 = (0x00FF00 & printerVersion) >>  8;
                NSUInteger fw3 =  0x0000FF & printerVersion;
                printerVersionString = [NSString stringWithFormat:@"%li.%li.%li", fw1, fw2, fw3];
                
                tweetText = [NSString stringWithFormat:@"@hpsupport #hpsprocket \nS:%@ F:%@ \n[%@]", appVersion, printerVersionString, enterText];
                tweetStringURL = [NSString stringWithFormat:@"http://twitter.com/intent/tweet?text=@hpsupport+%%23hpsprocket%%0aS:%@+F:%@+%%0a%%5B%@%%5D", appVersion, printerVersionString, enterTextURL];
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
        
        if ([navigationController.topViewController isKindOfClass:[PGWebViewerViewController class]]) {
            PGWebViewerViewController *webViewerViewController = (PGWebViewerViewController *)navigationController.topViewController;
            
            if ([segue.identifier isEqualToString:@"ViewUserGuideSegue"]) {
                webViewerViewController.trackableScreenName = @"View User Guide";
                webViewerViewController.url = kPGHelpAndHowToViewUserURL;
            } else if ([segue.identifier isEqualToString:@"VisitWebsiteSegue"]) {
                webViewerViewController.trackableScreenName = @"Visit Website";
                webViewerViewController.url = kPGHelpAndHowToVisitWebsiteURL;
            } else if ([segue.identifier isEqualToString:@"JoinForumSupportSegue"]) {
                webViewerViewController.trackableScreenName = @"Join Forum Support";
                webViewerViewController.url = kPGHelpAndHowToJoinForumSupportURL;
            }
        }
    }
}

@end
