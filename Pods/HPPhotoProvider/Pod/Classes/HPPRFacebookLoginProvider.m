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

#import <FacebookSDK/FacebookSDK.h>
#import "HPPRFacebookLoginProvider.h"
#import "HPPR.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    return self;
}

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            [self notifyLogin];
            if (completion) {
                completion(YES, nil);
            }
        } else {
            [FBSession openActiveSessionWithReadPermissions:FACEBOOK_PERMISSIONS allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                [self sessionStateChanged:session state:state error:error completion:completion];
            }];
        }
    }
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [self notifyLogout];

    if (completion) {
        completion(YES, nil);
    }
}

- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if( [self connectedToInternet:completion] ) {
        FBSessionState state = FBSession.activeSession.state;
        if (state == FBSessionStateCreatedTokenLoaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [FBSession openActiveSessionWithReadPermissions:FACEBOOK_PERMISSIONS allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                    [self sessionStateChanged:FBSession.activeSession state:status error:error completion:completion];
                }];
            });
        } else if (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended) {
            [self sessionStateChanged:FBSession.activeSession state:state error:nil completion:completion];
        } else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    [FBSession.activeSession setStateChangeHandler:nil];
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)handleDidBecomeActive
{
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

#pragma mark - Private methods

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error completion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if (!error && (state == FBSessionStateOpen || state == FBSessionStateOpenTokenExtended)){
        [self notifyLogin];
        if (completion) {
            completion(YES, nil);
        }
    } else {
        if (error) {
            [FBSession.activeSession closeAndClearTokenInformation];
            [self notifyLogout];
        }
        if (completion) {
            completion(NO, error);
        }
    }
}

@end
