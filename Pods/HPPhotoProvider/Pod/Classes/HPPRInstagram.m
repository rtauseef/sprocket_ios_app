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

#import "HPPRInstagram.h"
#import "HPPRAuthTokenService.h"

NSString *const kInstagramBaseURLString = @"https://api.instagram.com/v1/";

NSString *const kUserMediaRecentEndpoint = @"users/%@/media/recent";
NSString *const kUserMediaFeedEndpoint = @"users/self/feed";
NSString *const kUserUserProfileEndpoint = @"users/%@";
NSString *const kUserUserSearchEndpoint = @"users/search";
NSString *const kUserUserMediaSearchEndpoint = @"users/%@/media/recent";

NSString *const kUserTagSearchEndpoint = @"tags/search";
NSString *const kUserTagMediaSearchEndpoint = @"tags/%@/media/recent";

NSString *const kAuthenticationEndpoint = @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token";

@implementation HPPRInstagram

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
//        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
//        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return self;
}

+ (HPPRInstagram *)sharedClient
{
    static HPPRInstagram *sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kInstagramBaseURLString]];
    });
    
    return sharedClient;
}

- (NSString *)getAccessToken {
    return [HPPRAuthTokenService authTokenFor:HPPRAuthServiceInstagram];
}

- (void)setAccessToken:(NSString *)token {
    [HPPRAuthTokenService setAuthToken:token for:HPPRAuthServiceInstagram];
}

- (void)clearAccessToken
{
    [HPPRAuthTokenService clearAuthTokenFor:HPPRAuthServiceInstagram];

    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        BOOL isInstagram = ([[cookie domain] rangeOfString:@"instagram"].location != NSNotFound);
        if (isInstagram) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

@end
