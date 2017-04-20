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

#import <HPPRInstagramUser.h>
#import <HPPRInstagram.h>

#import <HPPRInstagramPhotoProvider.h>
#import <HPPRFacebookPhotoProvider.h>
#import <HPPRFlickrPhotoProvider.h>
#import <HPPRCameraRollPhotoProvider.h>
#import <HPPRPituPhotoProvider.h>
#import <HPPRQzonePhotoProvider.h>

#import <HPPRFacebookLoginProvider.h>
#import <HPPRInstagramLoginProvider.h>
#import <HPPRFlickrLoginProvider.h>
#import <HPPRCameraRollLoginProvider.h>
#import <HPPRPituLoginProvider.h>
#import <HPPRQzoneLoginProvider.h>

typedef NS_ENUM(NSUInteger, PGSocialSourceType) {
    PGSocialSourceTypeLocalPhotos = 0,
    PGSocialSourceTypeFacebook,
    PGSocialSourceTypeInstagram,
    PGSocialSourceTypeFlickr,
    PGSocialSourceTypePitu,
    PGSocialSourceTypeWeiBo,
    PGSocialSourceTypeQzone,
    PGSocialSourceTypeGoogle
};

extern NSString * const kSocialNetworkKey;
extern NSString * const kIncludeLoginKey;

@interface PGSocialSource : NSObject

@property (nonatomic, assign) PGSocialSourceType type;
@property (nonatomic, strong, readonly) UIImage *icon;
@property (nonatomic, strong, readonly) UIImage *menuIcon;
@property (nonatomic, assign, readonly) BOOL hasFolders;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, assign) BOOL needsSignIn;
@property (nonatomic, assign) BOOL isLogged;

@property (nonatomic, strong, readonly) HPPRLoginProvider *loginProvider;
@property (nonatomic, strong, readonly) HPPRSelectPhotoProvider *photoProvider;

- (instancetype)initWithSocialSourceType:(PGSocialSourceType)type;

@end
