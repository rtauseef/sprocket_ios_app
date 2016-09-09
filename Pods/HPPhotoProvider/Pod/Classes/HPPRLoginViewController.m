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

#import "HPPRLoginViewController.h"
#import "HPPR.h"
#import "UIColor+HPPRStyle.h"
#import "UIFont+HPPRStyle.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"
#import "HPPRAlertStripView.h"

@interface HPPRLoginViewController () <UIWebViewDelegate, HPPRAlertStripViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet HPPRAlertStripView *alertStripView;

@end

@implementation HPPRLoginViewController

float const kLoadTimeout = 10.0; // seconds
float kAlertAnimationDuration = 1.0; // seconds
float kMarginX = 20.0;
float kMarginY = 5.0;
float kAlertHeight = 50.0;
float kRetryWidth = 60.0;

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationBar *navBar = [self.navigationController navigationBar];
    [navBar setBarTintColor:[UIColor whiteColor]];
    [self.cancelButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor HPPRBlueColor], NSFontAttributeName:[UIFont HPPRNavigationBarButtonItemFont]} forState:UIControlStateNormal];
    self.webView.delegate = self;
    self.alertStripView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_TRACKABLE_SCREEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self screenName] forKey:kHPPRTrackableScreenNameKey]];
    [self startLogin];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self cancelLogin];
}

#pragma mark - Public methods

- (void)startLogin
{
    [self.webView stopLoading];
    self.spinner = [self.view HPPRAddSpinner];
}

- (NSString *)screenName
{
    return nil;
}

- (NSString *)providerName
{
    return nil;
}

- (void)cancelLogin
{
    [self stopTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PROVIDER_LOGIN_CANCEL_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kHPPRProviderName]];
}

- (void)loginError:(NSError *)error
{
    // do nothing
}

- (BOOL)handleURL:(NSURL *)url
{
    BOOL handle = YES;
    if (![url.scheme isEqual:@"http"] && ![url.scheme isEqual:@"https"]) {
#ifndef TARGET_IS_EXTENSION
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
            handle = NO;
        }
#endif
    }
    return handle;
}

#pragma mark - Timer

- (void)startTimer
{
    NSLog(@"TIMER START");
    float timeout = [HPPR sharedInstance].immediateLoginAlert ? 0.1f : kLoadTimeout;
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
}

- (void)stopTimer
{
    if (self.timer) {
        NSLog(@"TIMER STOP");
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerFired:(NSTimer *)timer
{
    [self stopTimer];
    [self showLoadWarning];
}

- (void)showLoadWarning
{
    self.alertStripView.alpha = 0.0;
    self.alertStripView.messageText = @"It appears to be taking a long time to load the login page.";
    self.alertStripView.actionText = @"Retry";
    self.alertStripView.transform = CGAffineTransformMakeTranslation(0, self.alertStripView.bounds.size.height);
    self.alertStripView.hidden = NO;
    [UIView animateWithDuration:kAlertAnimationDuration animations:^{
        self.alertStripView.alpha = 1.0;
        self.alertStripView.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideLoadWarning
{
    [self stopTimer];
    if (![HPPR sharedInstance].preventHideLoginAlert) {
        [UIView animateWithDuration:kAlertAnimationDuration animations:^{
            self.alertStripView.alpha = 0.0;
            self.alertStripView.transform = CGAffineTransformMakeTranslation(0, self.alertStripView.bounds.size.height);
        }];
    }
}

- (void)retryLogin
{
    [self.spinner removeFromSuperview];
    [self hideLoadWarning];
    [self startLogin];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", [request URL]);
    return [self handleURL:[request URL]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startTimer];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadWarning];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner removeFromSuperview];
    });
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoadWarning];
    NSLog(@"(webview) %@", error.description);
    
    if ((error.code == NO_INTERNET_CONNECTION_ERROR_CODE) ||
        (error.code == THE_REQUEST_TIME_OUT_ERROR_CODE) ||
        (error.code == THE_NETWORK_CONNECTION_WAS_LOST_ERROR_CODE) ||
        (error.code == A_SERVER_WITH_THE_SPECIFIED_HOSTNAME_COULD_NOT_BE_FOUND_ERROR_CODE)) {
        
        [self loginError:error];
    }
}

#pragma mark - HPPRAlertStripViewDelegate

- (void)actionButtonTapped:(HPPRAlertStripView *)alertStripView
{
    [self retryLogin];
}

@end
