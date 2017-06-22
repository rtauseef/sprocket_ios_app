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
#import "UIColor+Style.h"
#import "UIViewController+Trackable.h"
#import "PGLoggingSetttingsViewController.h"
#import "PGAppAppearance.h"

@interface PGAboutViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIButton *secretMenuButton;
@property (weak, nonatomic) UIWebView *sprocketView;

@end

@implementation PGAboutViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackableScreenName = @"About Screen";

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sprocketsButtonTapped:(id)sender {
    static int requiredNumberOfTaps       = 3;
    static NSTimeInterval maxSecondsToTap = 3;
    static NSDate *tapStartTime           = nil;
    static int numTaps                    = 0;
    
    NSTimeInterval secondsElapsed = -[tapStartTime timeIntervalSinceNow];
    
    if( numTaps >= requiredNumberOfTaps ) {
        numTaps = 0;
        
        CGFloat yOrigin = 50;
        if ([sender isKindOfClass:[UIButton class]]) {
            yOrigin = ((UIButton *)sender).frame.origin.y - 10;
        }
        
        UIImage *image = [UIImage imageNamed:@"Sprocket.gif"];
        CGRect frame = CGRectMake((self.view.frame.size.width - image.size.width)/2, yOrigin,
                                  image.size.width, image.size.height);
        UIWebView *webview = [[UIWebView alloc]initWithFrame:frame];
        NSURL *nsurl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sprocket.gif" ofType:nil]];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        [webview loadRequest:nsrequest];
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
        frame.origin.y += frame.size.height + 10;
        frame.size.height = 44;
        dismissButton.frame = frame;
        [dismissButton.titleLabel setFont:self.versionLabel.font];
        [dismissButton setTitleColor:[UIColor HPBlueButtonColor] forState:UIControlStateNormal];
        [dismissButton setTitle:@"My viewing experience is complete" forState:UIControlStateNormal];
        [dismissButton addTarget:self action:@selector(sprocketButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:webview];
        [self.view addSubview:dismissButton];
        self.sprocketView = webview;
    } else if( nil == tapStartTime ||
              maxSecondsToTap < secondsElapsed ) {
        
        tapStartTime = [NSDate date];
        numTaps = 0;
        
    } else if ( maxSecondsToTap >= secondsElapsed ) {
        
        numTaps++;
    }
}

- (IBAction)sprocketButtonTapped:(id)sender
{
    if (self.sprocketView) {
        [self.sprocketView removeFromSuperview];
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        [((UIButton *)sender) removeFromSuperview];
    }
}

- (IBAction)secretMenuButtonTapped:(id)sender
{
    static int requiredNumberOfTaps       = 5;
    static NSTimeInterval maxSecondsToTap = 5;
    static NSDate *tapStartTime           = nil;
    static int numTaps                    = 0;
    
    NSTimeInterval secondsElapsed = -[tapStartTime timeIntervalSinceNow];
    
    if( numTaps >= requiredNumberOfTaps ) {
        
        numTaps = 0;
        tapStartTime = nil;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Admin Menu" message:@"Please enter unlock code" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Code";
        }];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = [alert.textFields firstObject];
            PGLoggingSetttingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: @"PGLoggingSetttingsViewController"];
            if ([vc validCode:textField.text]) {
                vc.unlockCode = textField.text;
                [self.navigationController pushViewController: vc animated:YES];
            }
        }];
        [alert addAction:action];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
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
