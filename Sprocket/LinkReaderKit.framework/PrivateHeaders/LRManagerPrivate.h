//
//  LRManagerPrivate.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LinkReaderKit/LRManager.h>
#import "Keychainwrapper.h"
#import "LRLinkServices.h"

@protocol ExtendedLinkReaderDelegate <NSObject>

- (BOOL)getIconImageForAction:(id)action completion:(void(^)(UIImage *image))completion;

@end


@interface LRManager()

//------- Private ONLY -------------
@property (nonatomic, weak) id<ExtendedLinkReaderDelegate> extendedDelegate;
@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString *secret;
@property (readonly) NSString *accessToken;
@property (strong, nonatomic) NSString *configurationFilePath;
@property (nonatomic, strong) NSDictionary *serviceConfigurations;
@property (nonatomic, readwrite) LRAuthStatus authorizationStatus;
@property (strong, nonatomic) NSString *userEmail;
@property (nonatomic) NSString *userAccessToken;
@property (nonatomic) NSString *userRefreshToken;
@property (nonatomic) NSString *linkReaderAppBasicAuth;
@property (strong, nonatomic) KeychainWrapper *myKeyChainWrapper;

+ (NSError *) authError:(LRErrorCode) code;

/**
 Authenticates a partner app. The application's bundle id be included in the list of registered partner app ids.
 
 @param clientID    The client identifier
 @param secret      The client secret
 
 @since 1.1.2
*/
- (void)authorizePartnerAppWithClientID:(NSString *)clientID secret:(NSString *)secret;
- (void)authorizeLinkReaderWithClientID:(NSString *)clientID secret:(NSString *)secret;
- (void)saveUserEmail:email userAccessToken: accessToken userRefreshToken: refreshToken;
- (void)setAuthorizationStatus:(LRAuthStatus)status;
- (void)set:(LppStack)lppStack;
- (void)setRoleAuthenticationEnabled:(BOOL) enabled;
- (void)setConferenceModeEnabled:(BOOL)enabled;
+ (NSString *)defaultConfigurationFilePath;
+ (NSString*) digimarcSdkVersion;


/**
 Authenticates user with our Service to get access token for future Service calls
 
 @param email       The user provided email to login into the Service
 @param password    The user provided password  to login into the Service
 @param completion  The completion block to run upon completion
 
 @since ENTER_VERSION_HERE
 */
-(void)authenticateUserWithEmail:(NSString *)email andPassword:(NSString *)password completion:(void (^)(NSError *error))completion;

/**
 Displays a view controller to authenticate the user
 
 @param completion  The completion block to run upon completion
 
 @since ENTER_VERSION_HERE
 */
-(void)authenticateUserWithCompletion:(void (^)(NSError *error))completion;


-(void)refreshUserAccessTokenWithCompletion:(void (^)(NSError *error))completion;

/**
 Returns wheather a user is signed in or not
 
 @since ENTER_VERSION_HERE
 */
-(BOOL)userIsSignedIn;

/**
 The current user is signed out from the app
 
 @since ENTER_VERSION_HERE
 */
-(void)signUserOut;

/**
 The email of the signed in user
 
 @since ENTER_VERSION_HERE
 */
-(NSString *)userEmail;

@end


