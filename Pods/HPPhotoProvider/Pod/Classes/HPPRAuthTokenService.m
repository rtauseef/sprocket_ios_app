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

#import "HPPRAuthTokenService.h"
#import "HPPRKeychainService.h"


static NSString * const kAuthServiceTokenKeyInstagram = @"authtokenservice.instagram";
static NSString * const kAuthServiceTokenKeyFlickr    = @"authtokenservice.flickr";
static NSString * const kAuthServiceTokenKeyFacebook  = @"authtokenservice.facebook";
static NSString * const kAuthServiceTokenKeyQzone     = @"authtokenservice.qzone";

@implementation HPPRAuthTokenService

+ (NSString *)authTokenFor:(HPPRAuthService)authService {
    NSString *key = [HPPRAuthTokenService keyForAuthService:authService];

    return [[HPPRKeychainService sharedInstance] valueForKey:key];
}

+ (void)setAuthToken:(NSString *)authToken for:(HPPRAuthService)authService {
    NSString *key = [HPPRAuthTokenService keyForAuthService:authService];

    [[HPPRKeychainService sharedInstance] setValue:authToken forKey:key];
}

+ (void)clearAuthTokenFor:(HPPRAuthService)authService {
    NSString *key = [HPPRAuthTokenService keyForAuthService:authService];

    [[HPPRKeychainService sharedInstance] removeValueForKey:key];
}


#pragma mark - Private

+ (NSString *)keyForAuthService:(HPPRAuthService)authService {
    NSString *key;

    switch (authService) {
        case HPPRAuthServiceInstagram:
            key = kAuthServiceTokenKeyInstagram;
            break;
        case HPPRAuthServiceFlickr:
            key = kAuthServiceTokenKeyFlickr;
            break;
        case HPPRAuthServiceFacebook:
            key = kAuthServiceTokenKeyFacebook;
            break;
        case HPPRAuthServiceQzone:
            key = kAuthServiceTokenKeyQzone;
            break;
    }

    return key;
}

@end
