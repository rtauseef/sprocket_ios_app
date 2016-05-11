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

#import "HPPRInstagramLoginProvider.h"
#import "HPPR.h"
#import "HPPRInstagram.h"
#import "HPPRInstagramUser.h"
#import "HPPRInstagramLoginViewController.h"

@interface HPPRInstagramLoginProvider () <HPPRInstagramLoginViewControllerDelegate>

@property (strong, nonatomic) void (^completion)(BOOL loggedIn, NSError *error);

@end

@implementation HPPRInstagramLoginProvider

#pragma mark - Initialization

+ (HPPRInstagramLoginProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRInstagramLoginProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRInstagramLoginProvider alloc] init];
    });
    return sharedInstance;
}

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
        UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPRInstagramLoginNavigationViewController"];
        
        HPPRInstagramLoginViewController *instagramLoginViewController = (HPPRInstagramLoginViewController *)navigationController.topViewController;
        instagramLoginViewController.delegate = self;
        
        [self.viewController presentViewController:navigationController animated:YES completion:nil];
        
        self.completion = completion;
    }
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    [HPPRInstagramUser clearSaveUserProfile];
    
    [[HPPRInstagram sharedClient] clearAccessToken];
    
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if([[cookie domain] isEqualToString:@"instagram.com"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    
    [self notifyLogout];
    
    if (completion) {
        completion(YES, nil);
    }
}

- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        if (completion) {
            completion(!([[HPPRInstagram sharedClient] getAccessToken] == nil), nil);
        }
    }
}

#pragma mark - MCInstagramLoginViewControllerDelegate

- (void)instagramLoginViewControllerDidLogin:(HPPRInstagramLoginViewController *)instagramLoginViewController
{
    [self notifyLogin];
    if (self.completion) {
        self.completion(YES, nil);
    }
}

- (void)instagramLoginViewControllerDidCancel:(HPPRInstagramLoginViewController *)instagramLoginViewController
{
    if (self.completion) {
        self.completion(NO, nil);
    }
}


@end
