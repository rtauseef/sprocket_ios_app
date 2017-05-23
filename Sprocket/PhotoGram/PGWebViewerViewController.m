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

#import <HPPR.h>
#import "PGWebViewerViewController.h"
#import "UIView+Animations.h"

#define ALERT_VIEW_RETRY_BUTTON_INDEX 0
#define ALERT_VIEW_OK_BUTTON_INDEX 1

@interface PGWebViewerViewController () <UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation PGWebViewerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.spinner = [self.view addSpinner];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.webView.delegate = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    if (self.urlRequestHeaders) {
        request.allHTTPHeaderFields = self.urlRequestHeaders;
    }

    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner removeFromSuperview];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ((nil != self.notifyUrl) && [request.URL.absoluteString rangeOfString:self.notifyUrl].location != NSNotFound) {
        if ([self.delegate respondsToSelector:@selector(webViewerViewControllerDidReachNotifyUrl:)]) {
            [self.delegate webViewerViewControllerDidReachNotifyUrl:self];
        }
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code == NO_INTERNET_CONNECTION_ERROR_CODE) {
        [self.spinner removeFromSuperview];
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"Retry", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == ALERT_VIEW_RETRY_BUTTON_INDEX) {
        self.spinner = [self.view addSpinner];
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        [self.webView loadRequest:request];
        
    } else if (buttonIndex == ALERT_VIEW_OK_BUTTON_INDEX) {
        [self dismissViewControllerAnimated:YES completion:nil];

        if ([self.delegate respondsToSelector:@selector(webViewerViewControllerDidDismiss:)]) {
            [self.delegate webViewerViewControllerDidDismiss:self];
        }
    }
}

#pragma mark - Button actions

- (IBAction)doneButtonItemTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([self.delegate respondsToSelector:@selector(webViewerViewControllerDidDismiss:)]) {
        [self.delegate webViewerViewControllerDidDismiss:self];
    }
}

@end
