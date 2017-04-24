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

#import <Google/SignIn.h>
#import "HPPRGoogleLoginProvider.h"
#import "HPPR.h"
#import "HPPRCacheService.h"

static NSString * const kGoogleProviderName = @"Google";

@interface HPPRGoogleLoginProvider() <GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, copy) void (^completion)(BOOL loggedIn, NSError *error);
@property (strong, nonatomic) UINavigationController *navigationController;
@property (assign, nonatomic) BOOL loggedIn;

@end

@implementation HPPRGoogleLoginProvider

#pragma mark - Initialization

+ (HPPRGoogleLoginProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRGoogleLoginProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRGoogleLoginProvider alloc] init];
        NSError* configureError;
        [[GGLContext sharedInstance] configureWithError: &configureError];
        NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
        
        sharedInstance.loggedIn = NO;
        [[GIDSignIn sharedInstance] setScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/plus.login"]];
        [GIDSignIn sharedInstance].delegate = sharedInstance;
        [GIDSignIn sharedInstance].uiDelegate = sharedInstance;
        [[GIDSignIn sharedInstance] signInSilently];
    });
    return sharedInstance;
}

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        self.completion = completion;

        [[GIDSignIn sharedInstance] signIn];
    }
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    self.loggedIn = NO;
    [[GIDSignIn sharedInstance] disconnect];
    
    [self notifyLogout];
    
    if (completion) {
        completion(YES, nil);
    }
}

- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    BOOL loggedIn = FALSE;
    
    if( [self connectedToInternet:completion] ) {
        loggedIn = self.loggedIn  &&  [[GIDSignIn sharedInstance] hasAuthInKeychain];
    }
    
    if (completion) {
        completion(loggedIn, nil);
    }
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

#pragma mark - GIDSignInUIDelegate

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [[self topViewController] presentViewController:viewController animated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_TRACKABLE_SCREEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kHPPRTrackableScreenNameKey]];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (nil == error) {
        self.loggedIn = YES;
        
        // Perform any operations on signed in user here.
        NSString *userId = user.userID;
        NSString *idToken = user.authentication.idToken; // Safe to send to the server
        NSString *fullName = user.profile.name;
        NSString *imageURL = nil;
        if (user.profile.hasImage) {
            imageURL = [[user.profile imageURLWithDimension:50] absoluteString];
        }
        
        NSDictionary *googleUser = [[NSMutableDictionary alloc] init];
        [googleUser setValue:userId forKey:@"userID"];
        [googleUser setValue:fullName forKey:@"userName"];
        [googleUser setValue:imageURL forKey:@"imageURL"];
        [googleUser setValue:idToken forKey:@"idToken"];
        
        [self setUser:googleUser];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PROVIDER_LOGIN_SUCCESS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kHPPRProviderName]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PROVIDER_LOGIN_CANCEL_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kHPPRProviderName]];
    }

    if (self.completion) {
        self.completion(nil == error, error);
        self.completion = nil;
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
}

#pragma mark - Utilities
// The following was adapted from: http://stackoverflow.com/questions/6131205/iphone-how-to-find-topmost-view-controller

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (NSString *)providerName
{
    return kGoogleProviderName;
}

@end

