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
#import "HPPRAppearance.h"

#define HPPR_TRACKABLE_SCREEN_NOTIFICATION @"TrackableScreenNotification"
#define HPPR_PROVIDER_LOGIN_NOTIFICATION @"ProviderLoginNotification"
#define HPPR_PROVIDER_LOGIN_CANCEL_NOTIFICATION @"ProviderLoginCancelNotification"
#define HPPR_PROVIDER_LOGIN_SUCCESS_NOTIFICATION @"ProviderLoginSuccessNotification"
#define PROVIDER_STARTUP_NOTIFICATION @"ProviderStartupNotification"
#define HPPR_ALBUM_CHANGE_NOTIFICATION @"AlbumChangeNotification"
#define HPPR_PHOTO_COLLECTION_BEGIN_REFRESH @"PhotoCollectionBeginRefresh"
#define HPPR_PHOTO_COLLECTION_END_REFRESH @"PhotoCollectionEndRefresh"

#define FACEBOOK_PERMISSIONS @[@"public_profile", @"user_photos"]

#define FLICKR_MAX_PER_PAGE @"50"
#define FLICKR_MAX_FAVORITES_PER_PAGE @"50"
#define FLICKR_INVALID_TOKEN_ERROR_CODE 98

#define NO_INTERNET_CONNECTION_ERROR_CODE -1009
#define THE_REQUEST_TIME_OUT_ERROR_CODE -1001
#define THE_NETWORK_CONNECTION_WAS_LOST_ERROR_CODE -1005
#define A_SERVER_WITH_THE_SPECIFIED_HOSTNAME_COULD_NOT_BE_FOUND_ERROR_CODE -1003
#define THE_OPERATION_COULD_NOT_BE_COMPLETED_ERROR_CODE -999
#define REQUEST_FAIL_ERROR_CODE -1011

#define USER_ACCOUNT_IS_PRIVATE HPPRLocalizedString(@"you cannot view this resource", @"Message shown when the user account is private")
#define THE_ACCESS_TOKEN_IS_INVALID HPPRLocalizedString(@"The access_token provided is invalid.", @"Message shown when the token used to connect with the social network is invalid (could be because is expired for example)")

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0f)

#define IPHONE_LIST_COLLECTION_VIEW_SIZE ((IS_IPHONE_6 ? IPHONE_6_LIST_COLLECTION_VIEW_SIZE : (IS_IPHONE_6_PLUS ? IPHONE_6_PLUS_LIST_COLLECTION_VIEW_SIZE : IPHONE_4_AND_5_LIST_COLLECTION_VIEW_SIZE)))
#define IPHONE_4_AND_5_LIST_COLLECTION_VIEW_SIZE CGSizeMake(300, 300)
#define IPHONE_6_LIST_COLLECTION_VIEW_SIZE CGSizeMake(355, 355)
#define IPHONE_6_PLUS_LIST_COLLECTION_VIEW_SIZE CGSizeMake(394, 394)
#define IPAD_LIST_COLLECTION_VIEW_SIZE CGSizeMake(500, 500)
#define LIST_COLLECTION_VIEW_SIZE (IS_IPHONE ? IPHONE_LIST_COLLECTION_VIEW_SIZE : IPAD_LIST_COLLECTION_VIEW_SIZE)

#define IPHONE_GRID_COLLECTION_VIEW_SIZE ((IS_IPHONE_6 ? IPHONE_6_GRID_COLLECTION_VIEW_SIZE : (IS_IPHONE_6_PLUS ? IPHONE_6_PLUS_GRID_COLLECTION_VIEW_SIZE : IPHONE_4_AND_5_GRID_COLLECTION_VIEW_SIZE)))
#define IPHONE_4_AND_5_GRID_COLLECTION_VIEW_SIZE CGSizeMake(98, 98)
#define IPHONE_6_GRID_COLLECTION_VIEW_SIZE CGSizeMake(115, 115)
#define IPHONE_6_PLUS_GRID_COLLECTION_VIEW_SIZE CGSizeMake(128, 128)
#define IPAD_GRID_COLLECTION_VIEW_SIZE_PORTRAIT CGSizeMake(183, 183)
#define IPAD_GRID_COLLECTION_VIEW_SIZE_LANDSCAPE CGSizeMake(196, 196)
#define IPAD_GRID_COLLECTION_VIEW_SIZE ((IS_PORTRAIT) ? IPAD_GRID_COLLECTION_VIEW_SIZE_PORTRAIT : IPAD_GRID_COLLECTION_VIEW_SIZE_LANDSCAPE)
#define GRID_COLLECTION_VIEW_SIZE (IS_IPHONE ? IPHONE_GRID_COLLECTION_VIEW_SIZE : IPAD_GRID_COLLECTION_VIEW_SIZE)

#define IS_PORTRAIT UIDeviceOrientationIsPortrait((UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation)
#define IS_LANDSCAPE UIDeviceOrientationIsLandscape((UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation)

@interface HPPR : NSObject

extern NSString * const kHPPRTrackableScreenNameKey;
extern NSString * const kHPPRProviderName;

@property (nonatomic, strong) NSString *flickrAppKey;
@property (nonatomic, strong) NSString *flickrAppSecret;
@property (nonatomic, strong) NSString *flickrAuthCallbackURL;

@property (nonatomic, strong) NSString *instagramClientId;
@property (nonatomic, strong) NSString *instagramRedirectURL;
@property (nonatomic, assign) BOOL immediateLoginAlert;
@property (nonatomic, assign) BOOL preventHideLoginAlert;
@property (nonatomic, assign) BOOL showVideos;
@property (nonatomic, strong) HPPRAppearance *appearance;

@property (nonatomic, strong) NSString *qzoneAppId;
@property (nonatomic, strong) NSString *qzoneRedirectURL;

+ (HPPR *)sharedInstance;

@end
