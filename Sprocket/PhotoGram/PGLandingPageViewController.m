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

#import "PGLandingPageViewController.h"
#import "PGWebViewerViewController.h"
#import "SWRevealViewController.h"
#import "UIColor+Style.h"
#import "PGTermsAttributedLabel.h"
#import "UIViewController+trackable.h"
#import <CoreBluetooth/CoreBluetooth.h>

const NSInteger PGLandingPageViewControllerCollectionViewBottomInset = 120;

@interface PGLandingPageViewController () <UIGestureRecognizerDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *bluetoothManager;

@end

@implementation PGLandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       
    UIBarButtonItem *hamburgerButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"] style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
    
    self.navigationItem.leftBarButtonItem = hamburgerButtonItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_SWIPE_COACH_MARKS_NOTIFICATION object:nil];
    
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey: [NSNumber numberWithBool:YES] }];
}

- (void)setLinkForLabel:(TTTAttributedLabel *)label range:(NSRange)range
{
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [linkAttributes setValue:(__bridge id)[[UIColor HPLinkColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    label.linkAttributes = linkAttributes;
    label.activeLinkAttributes = linkAttributes;
    
    label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    label.delegate = self;
    label.text = label.text;
    
    [label addLinkToURL:[NSURL URLWithString:@"#"] withRange:range];
}

- (void)showLogin
{
    NSLog(@"Need to implement subclass showLogin function");
}

- (void)showAlbums
{
    NSLog(@"Need to implement subclass showAlbums function");
}

- (void)showNoConnectionAvailableAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Connection Available", nil)
                                                    message:NSLocalizedString(@"Please connect to a data source.\nYou can also use your device photos.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PG_Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"WebViewerNavigationController"];
    
    PGWebViewerViewController *webViewController = (PGWebViewerViewController *)navigationController.topViewController;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"];
    webViewController.url = path;
    webViewController.trackableScreenName = @"Terms of Service Screen";
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (CBCentralManagerStatePoweredOn == central.state) {
        NSLog(@"BLUETOOTH ON");
    } else {
        NSLog(@"BLUETOOTH NOT ON");
    }
}

@end
