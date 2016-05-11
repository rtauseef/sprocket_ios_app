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

#import "HPPRLoginProvider.h"
#import "HPPRReachability.h"
#import "HPPRError.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRLoginProvider

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if (completion) {
        completion(NO, [NSError errorWithDomain:@"HPPRLoginProvider" code:-1 userInfo:nil]);
    }
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    if (completion) {
        completion(NO, [NSError errorWithDomain:@"HPPRLoginProvider" code:-2 userInfo:nil]);
    }
}

- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if (completion) {
        completion(NO, [NSError errorWithDomain:@"HPPRLoginProvider" code:-3 userInfo:nil]);
    }
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    return NO;
}

- (void)handleDidBecomeActive
{
}

- (BOOL)connectedToInternet:(void (^)(BOOL loggedIn, NSError *error))completion
{
    BOOL bConnected = TRUE;
    
    HPPRReachability *networkReachability = [HPPRReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There is no internet connection");
        bConnected = FALSE;
        
        if( completion ) {
            completion(bConnected, [self internetConnectionError]);
        }

    }
    
    return bConnected;
}

- (NSError *)internetConnectionError
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[HPPR_ERROR_NO_INTERNET_CONNECTION_DESCRIPTION] forKeys:@[@"description"]];
    NSError * error = [NSError errorWithDomain:HPPR_ERROR_DOMAIN code:HPPR_ERROR_NO_INTERNET_CONNECTION userInfo:userInfo];
    return error;
}

- (void)notifyLogin
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoginWithProvider:)]) {
        [self.delegate didLoginWithProvider:self];
    }
}

- (void)notifyLogout
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLogoutWithProvider:)]) {
        [self.delegate didLogoutWithProvider:self];
    }
}

@end
