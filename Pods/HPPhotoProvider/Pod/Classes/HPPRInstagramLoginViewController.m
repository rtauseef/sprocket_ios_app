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

#import "HPPRInstagramLoginViewController.h"
#import "HPPR.h"
#import "HPPRInstagram.h"
#import "HPPRSelectPhotoCollectionViewController.h"
#import "HPPRInstagramPhotoProvider.h"
#import "UIColor+HPPRStyle.h"
#import "UIFont+HPPRStyle.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"

#define ALERT_VIEW_RETRY_BUTTON_INDEX 0
#define ALERT_VIEW_OK_BUTTON_INDEX 1

NSString * const kInstagramLoginScreenName = @"Instagram Login Screen";
NSString * const kInstagramProviderName = @"Instagram";

@interface HPPRInstagramLoginViewController () <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *images;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIAlertView *retryAlertView;

@end

@implementation HPPRInstagramLoginViewController

- (NSString *)screenName
{
    return kInstagramLoginScreenName;
}

- (NSString *)providerName
{
    return kInstagramProviderName;
}

- (void)startLogin
{
    [super startLogin];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kAuthenticationEndpoint, [HPPR sharedInstance].instagramClientId, [HPPR sharedInstance].instagramRedirectURL]]];
    [self.webView loadRequest:request];
}

- (void)cancelLogin
{
    if ([self.delegate respondsToSelector:@selector(instagramLoginViewControllerDidCancel:)]) {
        [self.delegate instagramLoginViewControllerDidCancel:self];
    }
    [super cancelLogin];
}

- (void)loginError:(NSError *)error
{
    if (self.retryAlertView == nil) {
        self.retryAlertView = [[UIAlertView alloc] initWithTitle:HPPRLocalizedString(@"Error", nil)
                                                         message:error.localizedDescription
                                                        delegate:self
                                               cancelButtonTitle:HPPRLocalizedString(@"Retry", @"Button caption")
                                               otherButtonTitles:HPPRLocalizedString(@"OK", @"Button caption"), nil];
    }
    
    [self.retryAlertView show];
}

- (BOOL)handleURL:(NSURL *)url
{
    BOOL handle = YES;
    NSString *urlString = url.absoluteString;
    
    if ([urlString rangeOfString:@"#access_token"].location != NSNotFound) {
        NSLog(@"User got the access token");
        NSString *params = [[urlString componentsSeparatedByString:@"#"] objectAtIndex:1];
        NSString *accessToken = [params stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
        [[HPPRInstagram sharedClient] setAccessToken:accessToken];
        if ([self.delegate respondsToSelector:@selector(instagramLoginViewControllerDidLogin:)]) {
            [self.delegate instagramLoginViewControllerDidLogin:self];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        handle = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PROVIDER_LOGIN_SUCCESS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kHPPRProviderName]];
    } else if ([urlString rangeOfString:@"error_reason=user_denied"].location != NSNotFound) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSString *text = HPPRLocalizedString(@"%@ uses Instagram photos to create awesome snapshots. Please allow %@ to access your Instagram photos in order to continue.", @"Message of an alert requesting authorization to access the Instagram photos");
            NSString *appName = [[HPPR sharedInstance].appearance.settings objectForKey:kHPPRAppName];
            text = [NSString stringWithFormat:text, appName, appName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:HPPRLocalizedString(@"Authorization Required", @"Title of an alert requesting authorization to access the Instagram photos")
                                                            message:text
                                                           delegate:nil
                                                  cancelButtonTitle:HPPRLocalizedString(@"OK", @"Button caption")
                                                  otherButtonTitles:nil];
            [alert show];
            
        }];
    }
    
    return handle;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == ALERT_VIEW_RETRY_BUTTON_INDEX) {
        [self startLogin];
    } else if (buttonIndex == ALERT_VIEW_OK_BUTTON_INDEX) {
        if ([self.delegate respondsToSelector:@selector(instagramLoginViewControllerDidCancel:)]) {
            [self.delegate instagramLoginViewControllerDidCancel:self];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
