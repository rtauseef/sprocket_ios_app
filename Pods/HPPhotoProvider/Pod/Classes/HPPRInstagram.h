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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AFHTTPSessionManager.h"

extern NSString *const kInstagramBaseURLString;
extern NSString *const kClientId;
extern NSString *const kRedirectUrl;

extern NSString *const kUserMediaRecentEndpoint;
extern NSString *const kUserMediaFeedEndpoint;
extern NSString *const kUserUserProfileEndpoint;
extern NSString *const kUserUserSearchEndpoint;
extern NSString *const kUserUserMediaSearchEndpoint;

extern NSString *const kUserTagSearchEndpoint;
extern NSString *const kUserTagMediaSearchEndpoint;

extern NSString *const kAuthenticationEndpoint;

extern NSString *const kUserAccessTokenKey;

@interface HPPRInstagram : AFHTTPSessionManager

+ (HPPRInstagram *)sharedClient;

- (NSString *)getAccessToken;
- (void)setAccessToken:(NSString *)token;
- (void)clearAccessToken;

@end
