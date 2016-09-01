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
    
    self.twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self.twitterComposeViewController addImage:[UIImage imageNamed:@"test.jpg"]];
    
    __weak typeof(self) weakSelf = self;
    [self.twitterComposeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
        [weakSelf.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] animated:YES];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            NSString *tweetText = nil;
            
            tweetText = NSLocalizedString(@"@hpsupport #hpsprocket [Emter Text]", nil);
            
            if (IS_OS_8_OR_LATER) {
                NSInteger numberOfPairedSprockets = [[MP sharedInstance] numberOfPairedSprockets];
                
                if (numberOfPairedSprockets > 0) {
                    tweetText = [NSString stringWithFormat:@"@hpsupport #hpsprocket S: %@ P: %@ [Emter Text]", @(1), @(2)];
                }
            }
            
            [self.twitterComposeViewController setInitialText:tweetText];
            
            [self presentViewController:self.twitterComposeViewController animated:YES completion:^{
                
            }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *navigationController = (UINavigationController *) segue.destinationViewController;
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

@end
