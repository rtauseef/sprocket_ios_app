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

#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "HPPRFacebookLoginProvider.h"
#import "HPPR.h"

static NSString * const kFacebookProviderName = @"Facebook";

@implementation HPPRFacebookLoginProvider

#pragma mark - Initialization

+ (HPPRFacebookLoginProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRFacebookLoginProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRFacebookLoginProvider alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        if (nil != [FBSDKAccessToken currentAccessToken]) {
            [self notifyLogin];
            if (completion) {
                completion(YES, nil);
            }
        } else {
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
            UIViewController *topViewController = [self topViewController];
            [loginManager logInWithReadPermissions:FACEBOOK_PERMISSIONS fromViewController:topViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_TRACKABLE_SCREEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ Login Screen",[self providerName]] forKey:kHPPRTrackableScreenNameKey]];
                if (completion) {
                    if (error) {
                        completion(NO, error);
                    } else if (nil == [FBSDKAccessToken currentAccessToken]) {
                        completion(NO, [self loginProblemError]);
                        // No token and no error mean the user hit "Done" without logging in
                        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PROVIDER_LOGIN_CANCEL_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kHPPRProviderName]];
                    } else {
                        completion(YES, nil);
                        [[NSNotificationCenter defaultCenter] postNotificationName:HPPR_PROVIDER_LOGIN_SUCCESS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[self providerName] forKey:kHPPRProviderName]];
                    }
                }
            }];
        }
    }
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [self notifyLogout];

    if (completion) {
        completion(YES, nil);
    }
}

- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        if (completion) {
            BOOL loggedIn = (nil != [FBSDKAccessToken currentAccessToken]);
            completion(loggedIn, nil);
        }
    }
}

- (BOOL)handleApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}


- (BOOL)handleApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:sourceApplication
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)handleDidBecomeActive
{
    [FBSDKAppEvents activateApp];
}


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
    return kFacebookProviderName;
}

@end
