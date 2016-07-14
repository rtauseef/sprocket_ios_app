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
#import "HPPRFlickrLoginProvider.h"
#import "HPPR.h"
#import "HPPRFlickrLoginViewController.h"
#import "HPPRCacheService.h"

@interface HPPRFlickrLoginProvider() <HPPRFlickrLoginViewControllerDelegate>

@property (nonatomic, strong) FKDUNetworkOperation *finishAuthOperation;
@property (nonatomic, strong) FKDUNetworkOperation *checkAuthOperation;
@property (nonatomic, strong) void (^completion)(BOOL loggedIn, NSError *error);
@property (strong, nonatomic)UINavigationController *navigationController;

@end

@implementation HPPRFlickrLoginProvider

#pragma mark - Initialization

+ (HPPRFlickrLoginProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRFlickrLoginProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRFlickrLoginProvider alloc] init];
        [[FlickrKit sharedFlickrKit] initializeWithAPIKey:[HPPR sharedInstance].flickrAppKey sharedSecret:[HPPR sharedInstance].flickrAppSecret];
    });
    return sharedInstance;
}

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPR" bundle:nil];
        self.navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPRFlickrLoginNavigationViewController"];
        
        HPPRFlickrLoginViewController *flickrLoginViewController = (HPPRFlickrLoginViewController *)self.navigationController.topViewController;
        flickrLoginViewController.delegate = self;
        
        [self.viewController presentViewController:self.navigationController animated:YES completion:nil];
        
        self.completion = completion;
    }
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    [[FlickrKit sharedFlickrKit] logout];
    
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        BOOL isFlickr = ([[cookie domain] rangeOfString:@"flickr"].location != NSNotFound);
        BOOL isYahoo = ([[cookie domain] rangeOfString:@"yahoo"].location != NSNotFound);
        if(isFlickr || isYahoo) {
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
        self.checkAuthOperation = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
            if (error) {
                self.user = nil;
                if (completion) {
                    completion(NO, error);
                }
            } else {
                NSString *url = [[[FlickrKit sharedFlickrKit] buddyIconURLForUser:userId] absoluteString];
                self.user = @{@"userName":userName, @"userID":userId, @"fullName":fullName, @"imageURL":url};
                if (completion) {
                    completion(YES, nil);
                }
            }
        }];
    }
}

- (BOOL)handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation
{
    self.finishAuthOperation = [[FlickrKit sharedFlickrKit] completeAuthWithURL:url completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
        self.user = nil;
        if (!error) {
            NSString *url = [[[FlickrKit sharedFlickrKit] buddyIconURLForUser:userId] absoluteString];
            self.user = @{@"userName":userName, @"userID":userId, @"fullName":fullName, @"imageURL":url};
            [self notifyLogin];
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (self.completion) {
                self.completion((error == nil), error);
            }
        }];
    }];
    
    return YES;
}

- (void)setUser:(NSDictionary *)user
{
    _user = user;
    NSString *url = [user objectForKey:@"imageURL"];
    if (url) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[HPPRCacheService sharedInstance] imageForUrl:url];
        });
    }
}

#pragma mark - MCFlickrLoginViewControllerDelegate

- (void)flickrLoginViewControllerDidFail:(HPPRFlickrLoginViewController *)flickrLoginViewController
{
    if (self.completion) {
        self.completion(NO, [NSError errorWithDomain:@"HPPRFlickrLoginProvider" code:-1 userInfo:nil]);
    }
}

- (void)flickrLoginViewControllerDidCancel:(HPPRFlickrLoginViewController *)flickrLoginViewController
{
    [self.finishAuthOperation cancel];
    [self.checkAuthOperation cancel];
    
    if (self.completion) {
        self.completion(NO, [NSError errorWithDomain:@"HPPRFlickrLoginProvider" code:-1 userInfo:nil]);
    }
}

@end

