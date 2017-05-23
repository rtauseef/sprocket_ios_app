//
//  PGMetarSocial.h
//  Sprocket
//
//  Created by Fernando Caprio on 5/9/17.
//  Copyright © 2017 HP. All rights reserved.
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
