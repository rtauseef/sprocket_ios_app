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

@protocol HPPRLoginProviderDelegate;

@interface HPPRLoginProvider : NSObject

@property (weak, nonatomic) id<HPPRLoginProviderDelegate>delegate;

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion;
- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion;
- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion;

- (BOOL)handleApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (void)handleDidBecomeActive;

- (BOOL)connectedToInternet:(void (^)(BOOL loggedIn, NSError *error))completion;

- (NSError *)loginProblemError;

- (void)notifyLogin;
- (void)notifyLogout;

@end

@protocol HPPRLoginProviderDelegate <NSObject>

@optional

- (void)didLoginWithProvider:(HPPRLoginProvider *)loginProvider;
- (void)didLogoutWithProvider:(HPPRLoginProvider *)loginProvider;

@end