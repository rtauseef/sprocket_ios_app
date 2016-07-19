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

#import "PGAboutViewController.h"
#import "UIFont+Style.h"
#import "UIViewController+Trackable.h"
#import "PGLoggingSetttingsViewController.h"
#import "PGAppAppearance.h"

@interface PGAboutViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIButton *secretMenuButton;

@end

@implementation PGAboutViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"About Screen";
    
    self.titleLabel.font = [UIFont HPSimplifiedLightFontWithSize:28.0f];
    self.versionLabel.font = [UIFont HPSimplifiedRegularFontWithSize:14.0f];
    self.copyrightLabel.font = [UIFont HPSimplifiedLightFontWithSize:12.0f];
    self.companyLabel.font = [UIFont HPSimplifiedLightFontWithSize:12.0f];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version %@ (%@)", @"Version number and build of the app"), version, build];
    
    [PGAppAppearance addGradientBackgroundToView:self.view];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)secretMenuButtonTapped:(id)sender {
    static int requiredNumberOfTaps       = 10;
    static NSTimeInterval maxSecondsToTap = 5;
    static NSDate *tapStartTime           = nil;
    static int numTaps                    = 0;
    
    NSTimeInterval secondsElapsed = -[tapStartTime timeIntervalSinceNow];
    
    if( numTaps >= requiredNumberOfTaps ) {
        
        numTaps = 0;
        tapStartTime = nil;
        
        // launch menu
        PGLoggingSetttingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: @"PGLoggingSetttingsViewController"];
        [self.navigationController pushViewController: vc animated:YES];
        
    }
    else if( nil == tapStartTime ||
             maxSecondsToTap < secondsElapsed ) {
        
        tapStartTime = [NSDate date];
        numTaps = 0;
        
    } else if ( maxSecondsToTap >= secondsElapsed ) {
        
        numTaps++;
    }
}

@end
