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
#import "PGMetarSocialActivity.h"

@interface PGMetarSocial : NSObject

typedef NS_ENUM(NSInteger, PGMetarSocialProvider) {
    PGMetarSocialProviderUnknown,
    PGMetarSocialProviderFacebook,
    PGMetarSocialProviderInstagram,
    PGMetarSocialProviderGoogle,
    PGMetarSocialProviderFlickr,
    PGMetarSocialProviderWikipedia
};

typedef NS_ENUM(NSInteger, PGMetarSocialType) {
    PGMetarSocialTypeUnknown,
    PGMetarSocialTypePost,
    PGMetarSocialTypePicture,
    PGMetarSocialTypeVideo
};

@property (assign, nonatomic) PGMetarSocialProvider provider;
@property (assign, nonatomic) PGMetarSocialType type;
@property (strong, nonatomic) NSString* uri;
@property (strong, nonatomic) NSString* assetId;
@property (strong, nonatomic) NSString* profileUri;
@property (strong, nonatomic) NSString* profileId;
@property (strong, nonatomic) PGMetarSocialActivity* activity;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
