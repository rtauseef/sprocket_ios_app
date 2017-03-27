//
//  LRPrivateConstants.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

@import Foundation;

#ifndef LinkReaderSDK_LRPrivateConstants_h
#define LinkReaderSDK_LRPrivateConstants_h

#define IPAD    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define IPHONE  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone

#define DEFAULT_NETWORK_REQUEST_TIMEOUT  30.0

#define RESOURCE_OWNER_ACCESS_TOKEN_URL @"https://www.livepaperapi.com/auth/v2/token"

FOUNDATION_EXPORT NSString * const LR_AUTH_ERROR_DOMAIN;
FOUNDATION_EXPORT NSString * const LR_CONFIGURATION_ERROR_DOMAIN;

FOUNDATION_EXPORT NSString * const LR_SERVICES_CONFIG_KEY_PREFIX;


#define REQUEST_TOKEN_URL  @"https://www.linkcreationstudio.com/auth/v1/token"
#define DEFAULT_RESOLVER_URL @"https://resolve.livepaperapi.com/resolver/resolve"
#define STAGING_RESOLVER_URL @"https://stage.resolve.livepaperapi.com/resolver/resolve"
#define DEV_RESOLVER_URL @"https://dev.resolve.livepaperapi.com/resolver/resolve"

#define LR_SERVICES_CONFIG_URL @"https://www.linkcreationstudio.com/sdk/v1/serivces"

#define KEY_ICON_CACHE_VERSION @"app.iconCacheVersion"
#define KEY_ICON_CACHE_DICTIONARY @"app.iconCacheDictionary"

#pragma mark - Error Constants

// first defined in LRCaptureManager -startScanning:
#define LR_AUTHORIZATION_GENERAL_ERROR_DESCRIPTION  @"The LRManager has not been authorized"
#define LR_AUTHORIZATION_GENERAL_ERROR_RECOVERY  @"Make sure your API key and secret are correct."

#define LR_CAMERA_METADATA_ERROR @"There was an error attempting to add the metadata detector"
#define LR_CAMERA_METADATA_ERROR_RECOVERY @"Please check and try re-adding the metadata detector"

#define LR_AUTHORIZATION_INVALID @"Authorization failed - the API key + secret are invalid"
#define LR_AUTHORIZATION_NETWORK_ERROR @"Authorization failed due to a network error"

#define LR_USER_AUTHORIZATION_INVALID @"Login failed - Incorrect email or password"
#define LR_USER_AUTHORIZATION_NETWORK_ERROR @"Login failed due to a network error"
#define LR_USER_AUTHORIZATION_UNEXPECTED_ERROR @"Login failed due to an unexpected error"

#define LR_AUTHORIZATION_ALREADY_AUTHORIZED @"The app is already authorized; cancelling re-authorization"
#define LR_AUTHORIZATION_KEY_NOT_FOUND @"The required API Key and/or Secret are missing"

#define LR_PAYOFF_ERROR_UNKNOWN_PAYOFF_FOUND_ERROR @"A payoff was found, but it could not be displayed."
#define LR_PAYOFF_ERROR_UNKNOWN_PAYOFF_FOUND_ERROR_RECOVERY @"If you are the payoff creator, check the contents + format and try again"

#define LR_CAMERA_ERROR @"There was an error with the camera session"
#define LR_CAMERA_ERROR_RECOVERY @"Please try again"

#define LR_CAMERA_ERROR_PERMISSIONS @"Camera access has been denied or restricted."
#define LR_CAMERA_ERROR_PERMISSIONS_RECOVERY @"Please allow camera access in the device's privacy settings."

#define HP_BLUE [UIColor colorWithRed:0.09 green:0.59 blue:0.83 alpha:1.0]
#define BODY_TEXT_COLOR [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0]
#define BODY_TEXT_SIZE 14.0f
#define UI_SCALE_FACTOR_NORMAL 1.0
#define UI_SCALE_FACTOR_LARGE 1.5

#define SHOW_DEBUG_COLORS 0

#endif
