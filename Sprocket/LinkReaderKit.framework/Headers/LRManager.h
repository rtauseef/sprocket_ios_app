//
//  LRManager.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <LinkReaderKit/LRPayoff.h>
#import <AVFoundation/AVFoundation.h>

/**
 Enumerates the current state of the camera and frame scanner.
 
 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRCaptureState){
    /**
     The camera is not available for use
     
     @since 1.0
     */
    LRCameraNotAvailable = -1,
    /**
     The camera has stopped, and is not sending frames
     
     @since 1.0
     */
    LRCameraStopped = 0,
    /**
     The camera has started and is sending frames
     
     @since 1.0
     */
    LRCameraRunning,
    /**
     The camera is running, and frames are being processed for data.
     
     @since 1.0
     */
    LRScannerRunning,
};

/**
 LinkReader Authorization Error Codes
 
 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRErrorCode){
    /**
     Either the API key or secret are missing
     
     @since 1.0
     */
    LRAuthErrorCode_ApiKeyNotFound = -400,
    /**
     The API key+secret combo are invalid
     
     @since 1.0
     */
    LRAuthErrorCode_ApiKeyInvalid = -401,
    /**
     Either the user email or password are invlaid
     
     @since ENTER_VERSION_HERE
     */
    LRAuthErrorCode_UserLoginFailed = -402,
    
    /**
     The user canceled the login flow
     
     @since ENTER_VERSION_HERE
     */
    LRAuthErrorCode_UserLoginCanceled = -403,    
    
    /**
     The application has already received authorization
     
     @since 1.0
     */
    LRAuthErrorCode_AlreadyAuthorized = -801,
    /**
     There was a network error while attempting to authorize
     
     @since 1.0
     */
    LRAuthErrorCode_NetworkError =  -1009,
    /**
     The user has cancelled the request
     
     @since 1.0
     */
    LRAuthErrorCode_RequestCancelled = -999,
    
    /**
     Unknown Payoff, error, has occurred
     
     @since 1.0
     */
    LRErrorCode_UnknownPayoff = 100,
    /**
     There was an unexpected error while attempting to authorize
     
     @since ENTER_VERSION_HERE
     */
    LRAuthErrorCode_UnexpectedError =  -9009,
};

/**
 These are the various authorization states of the SDK. Before the SDK can become useful, it must be authorized using -authorizeWithClientID:secret:success:failure: . A
 
 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRAuthStatus){
    /**
     Authorization is unknown - likely has not yet been initiated.
     
     @since 1.0
     */
    LRAuthStatusUnknown = -1,
    /**
     Authorization is in process and has not yet been completed.
     
     @since 1.0
     */
    LRAuthStatusAuthorizing = 0,
    /**
     The SDK has been successfully authorized.
     
     @since 1.0
     */
    LRAuthStatusAuthorized,
    /**
     Authorization failed with an error and must be attempted again.
     
     @since 1.0
     */
    LRAuthStatusError
};

extern NSString *const LinkReaderErrorDomain;


#pragma mark -

/**
 The primary purpose of LRManager is to allow the developer user to have finer-grained control over interaction with the LinkReaderSDK. If you wish to use a simple plug-n-play scanning + presentation option, see EasyReadingViewController. The LRManager (Extended) is the central managing class for various components of LinkReaderKit.
 
 Typical usage involves the following workflow
 
 1. In your view controller, set the delegate on the shared instance : `[[LRManager sharedManager] setDelegate:self]`
 2. Retrieve the video preview layer from LRManager and insert it into your preview subview
 3. Authorize the SDK using -authorizeWithClientID:secret:success:failure: , and begin scanning once the authorization is completed successfully
 
 @since 1.0
 */
@interface LRManager : NSObject

/**
 Current version of the LRManager
 @discussion Get the current version of the LRManager

 @return The current SDK version
 
 @since 1.0
 */
+ (NSString*) version;

/**
 Provides the current authorization status with regards to validating the API Key + Secret credentials.
 
 @since 1.0
 */
@property (nonatomic, readonly) LRAuthStatus authorizationStatus;

/**
 The access token of the signed in user
 
 @since ENTER_VERSION_HERE
 */
@property (nonatomic, readonly) NSString * userAccessToken;

/**
 The access token of the signed in user
 
 @since ENTER_VERSION_HERE
 */
@property (nonatomic, readonly) NSString * userRefreshToken;



/**
 Get a shared instance of the LRManager
 @discussion A convenient method to return a shared instance of the LRManager

 @return A LRManager instance created by createWithClientID or nil if no LRManager has been created yet.
 
 @since 1.0
 */
+ (LRManager*) sharedManager;

/**
 In order to use the core functionality of the SDK, you must request authorization using the clientID and secret provided to you upon registration with the LinkCreationStudio.com website. Once authorized, you may begin processing camera input for various kinds of content. Authorization only need to occur once per application launch, and does not require refresh.
 
 @param clientID The clientID provided in your account
 @param secret   The client secret provided in your account
 @param success  The completion block to run upon successful authentication
 @param failure  The completion block to run upon auth failure
 
 @since 1.0
 */
- (void)authorizeWithClientID:(NSString *)clientID secret:(NSString *)secret success:(void (^)(void))success failure:(void (^)(NSError * error))failure;

/**
 Returns the current authorization status of the LinkReaderKit SDK
 
 @return YES if authorized
 
 @since 1.0
 */
- (BOOL)isAuthorized;

@end
