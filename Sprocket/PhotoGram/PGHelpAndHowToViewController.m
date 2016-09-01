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

#import <Social/Social.h>

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
    [self.twitterComposeViewController setInitialText:@"First post from my iPhone app"];
    [self.twitterComposeViewController addURL:[NSURL URLWithString:@"http://www.appcoda.com"]];
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
            [self presentViewController:self.twitterComposeViewController animated:YES completion:^{
                
            }];
        }
    }
}

@end
