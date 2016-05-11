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

#import "FlickrKit.h"
#import "HPPRFlickrLoginViewController.h"
#import "HPPR.h"
#import "HPPRFlickrLoginProvider.h"
#import "HPPRSelectPhotoCollectionViewController.h"
#import "UIColor+HPPRStyle.h"
#import "UIFont+HPPRStyle.h"
#import "UIView+HPPRAnimation.h"
#import "NSBundle+HPPRLocalizable.h"

#define ALERT_VIEW_RETRY_BUTTON_INDEX 0
#define ALERT_VIEW_OK_BUTTON_INDEX 1
#define FLICKR_NO_INTERNET_CONNECTION_ERROR_CODE 200

NSString * const kFlickrLoginScreenName = @"Flickr Login Screen";

@interface HPPRFlickrLoginViewController () <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) FKDUNetworkOperation *startAuthOperation;
@property (nonatomic, strong) NSArray *images;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIAlertView *retryAlertView;
@property (nonatomic, strong) NSURL *lastURL;

@end

@implementation HPPRFlickrLoginViewController

- (NSString *)screenName
{
    return kFlickrLoginScreenName;
}

- (void)startLogin
{
    [super startLogin];
    if (self.lastURL) {
        [self loadURL:self.lastURL];
    } else {
        [self beginFlickrAuth];
    }
}

- (void)cancelLogin
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.startAuthOperation cancel];
    if ([self.delegate respondsToSelector:@selector(flickrLoginViewControllerDidCancel:)]) {
        [self.delegate flickrLoginViewControllerDidCancel:self];
    }
    [super cancelLogin];
}

- (void)loginError:(NSError *)error
{
    [self performSelector:@selector(showRetryAlertView:) withObject:error afterDelay:2.0];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == ALERT_VIEW_RETRY_BUTTON_INDEX) {
        [self startLogin];
    } else if (buttonIndex == ALERT_VIEW_OK_BUTTON_INDEX) {
        [self.startAuthOperation cancel];
        if ([self.delegate respondsToSelector:@selector(flickrLoginViewControllerDidCancel:)]) {
            [self.delegate flickrLoginViewControllerDidCancel:self];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private methods

- (void)showRetryAlertView:(NSError *)error
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

- (void)beginFlickrAuth
{
    self.startAuthOperation = [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:[NSURL URLWithString:[HPPR sharedInstance].flickrAuthCallbackURL] permission:FKPermissionRead completion:^(NSURL *flickrLoginPageURL, NSError *error) {
        if (error) {
            
            NSLog(@"(Flickr) %@", error.description);

            if ([self.delegate respondsToSelector:@selector(flickrLoginViewControllerDidFail:)]) {
                [self.delegate flickrLoginViewControllerDidFail:self];
            }
            
            if ((error.code == FLICKR_NO_INTERNET_CONNECTION_ERROR_CODE) ||
                (error.code == NO_INTERNET_CONNECTION_ERROR_CODE) ||
                (error.code == THE_REQUEST_TIME_OUT_ERROR_CODE) ||
                (error.code == THE_NETWORK_CONNECTION_WAS_LOST_ERROR_CODE) ||
                (error.code == A_SERVER_WITH_THE_SPECIFIED_HOSTNAME_COULD_NOT_BE_FOUND_ERROR_CODE)) {
                [self performSelector:@selector(showRetryAlertView:) withObject:error afterDelay:2.0];
            }
        } else {
            [self loadURL:flickrLoginPageURL];
        }
    }];
}

- (void)loadURL:(NSURL *)url
{
    self.lastURL = url;
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [self.webView loadRequest:urlRequest];

}

@end
