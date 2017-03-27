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
 The error domain string used when LinkReader authentication errors are generated. See LRAuthorizationErrorDomain for error types.
 
 @since 1.0
 */
FOUNDATION_EXPORT NSString *const LRAuthorizationErrorDomain;

/**
 Error Codes for LRAuthorizationErrorDomain
 
 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRAuthorizationError){
    /**
     Either the API key or secret are missing
     
     @since 1.0
     */
    LRAuthorizationErrorApiKeyNotFound,
    /**
     The API key+secret combo are invalid
     
     @since 1.0
     */
    LRAuthorizationErrorApiKeyInvalid,
    /**
     There was a network error while attempting to authorize
     
     @since 1.0
     */
    LRAuthorizationErrorNetworkError,
    /**
     There was an unexpected error while attempting to authorize
     
     @since 2.1
     */
    LRAuthorizationErrorUnexpectedError,
};


/**
 These are the various authorization states of the SDK. Before the SDK can become useful, it must be authorized using -authorizeWithClientID:secret:success:failure:
 
 @since 1.0
 */
typedef NS_ENUM(NSInteger, LRAuthStatus){
    /**
     Authorization is unknown - likely has not yet been initiated.
     
     @since 1.0
     */
    LRAuthStatusUnknown,
    /**
     Authorization is in process and has not yet been completed.
     
     @since 1.0
     */
    LRAuthStatusAuthorizing,
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


/**
 The primary purpose of the LRManager/`LRDetection`/`LRCaptureManager`/`LRPresenter` classes is to allow the developer user to have finer-grained control over interaction with the LinkReaderSDK. If you wish to use a simple plug-n-play scanning + presentation option, see `EasyReadingViewController`.
 
 The LRManager is the class that handles authorizing applications and some other core functions of the LinkReaderSDK.
 
 A typical usage of the LRManager/LRDetection/LRCaptureManager/LRPresenter classes involve the following workflow:
 
 In your view controller, set the delegate on the `LRDetection` and `LRCaptureManager` shared instance and implement the required methods on the `LRDetectionDelegate` and the `LRCaptureDelegate` protocol:
 
    ```
    [[LRDetection sharedManager] setDelegate:self]
    [[LRCaptureManager sharedManager] setDelegate:self]
    ```
 
 Retrieve the video preview layer from `LRCaptureManager` and insert it into your preview subview. Please refer to the sample app for the complete code .
 
    ```
     LRCaptureManager *captureManager = [LRCaptureManager sharedManager];
     captureManager.delegate = self;
     [captureManager stopSession];
     [self.previewLayer removeFromSuperlayer]; 
     if ([captureManager startSession] ){
        self.previewLayer = [captureManager previewLayer];
        [self.previewLayer setFrame:self.view.bounds];
        [self.view.layer addSublayer:self.previewLayer];
     }
    ```
 
 Authorize your app with the SDK and begin scanning once the authorization is completed successfully:
 
    ```
     [[LRManager sharedManager] authorizeWithClientID:self.clientID secret:self.clientSecret success:^{
        ...
        NSError *error;
        [[LRCaptureManager sharedManager] startScanning: &error];
        ...
     } failure:^(NSError *error) {
        ...
     }];
    ```
 
 When the application detects some content, the didFindPayoff: of the `LRDetectionDelegate` will be called with the payoff data. Present the payoff data using the `LRPresenter` class.
 
    ```
     - (void)didFindPayoff:(id<LRPayoff> )payoff{
        LRPresenter *presenter = [[LRPresenter alloc] init];
 
        // Check that we can indeed present the payoff view using a built-in presentation
        if ( [self.presenter canPresentPayoff:payoff]) {
            //Set the delgate to receive notifications when presented view controller will appear/dismiss
            self.presenter.delegate = self;
            // Present the payoff view
            [self.presenter presentPayoff:payoff viewController:self];
        } else {
            //Handle error
            ...
        }
    }
    ```
 
 @since 1.0
 */
@interface LRManager : NSObject

/**
 Current version of the LinkReaderSDK
 @discussion Get the current version of the LinkReaderSDK

 @return The current SDK version
 
 @since 1.0
 */
+ (NSString*)version;

/**
 Provides the current authorization status with regards to validating the application with API Key + Secret credentials.
 
 @since 1.0
 */
@property (nonatomic, readonly) LRAuthStatus authorizationStatus;

/**
 The access token of the signed-in user
 
 @since 2.1
 */
@property (nonatomic, readonly) NSString * userAccessToken;

/**
 The access token of the signed-in user
 
 @since 2.1
 */
@property (nonatomic, readonly) NSString * userRefreshToken;



/**
 Get a shared instance of the LRManager.

 @return The LRManager shared instance
 
 @since 1.0
 */
+ (LRManager*)sharedManager;

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
