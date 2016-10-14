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

#import <AssetsLibrary/AssetsLibrary.h>
#import "HPPRCameraRollLoginProvider.h"
#import "HPPR.h"
#import "NSBundle+HPPRLocalizable.h"

// Needed to suppress iOS 7 check for UIApplicationOpenSettingsURLString
#pragma GCC diagnostic ignored "-Wtautological-pointer-compare"

int const kCameraRollCancelButtonIndex = 0;

@interface HPPRCameraRollLoginProvider() <UIAlertViewDelegate>

@property (strong, nonatomic) void(^accessCompletion)(BOOL granted);

@end

@implementation HPPRCameraRollLoginProvider

#pragma mark - Initialization

+ (HPPRCameraRollLoginProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRCameraRollLoginProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRCameraRollLoginProvider alloc] init];
    });
    return sharedInstance;
}

- (void)loginWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    [self photoAccessWithCompletion:^(BOOL granted) {
        if (granted) {
            [self notifyLogin];
        }
        if (completion) {
            completion(granted, nil);
        }
    }];
}

- (void)logoutWithCompletion:(void (^)(BOOL loggedOut, NSError *error))completion
{
    [self notifyLogout];
    if (completion) {
        completion(YES, nil);
    }
}

- (void)checkStatusWithCompletion:(void (^)(BOOL loggedIn, NSError *error))completion
{
    if (completion) {
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        BOOL loggedIn = (ALAuthorizationStatusAuthorized == authorizationStatus);
        completion(loggedIn, nil);
    }
}

#pragma mark - Photo access

- (void)photoAccessWithCompletion:(void(^)(BOOL granted))completion
{
    self.accessCompletion = completion;
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    if (ALAuthorizationStatusDenied == authorizationStatus) {
        NSString *msgText = HPPRLocalizedString(@"Allow access in your Settings to print and save your photos.", @"Message of an alert when the user has denied the permission to access the Photos of the device");

        [self noAccessWithCaption:HPPRLocalizedString(@"Photo Access Required", @"Title of an alert when the user has denied the permission to access the Photos of the device")
                       andMessage:msgText];
    } else if (ALAuthorizationStatusRestricted == authorizationStatus) {
        [self noAccessWithCaption:HPPRLocalizedString(@"Photo Access Restricted", @"Title of an alert when the application is not authorized to access photo data.")
                       andMessage:HPPRLocalizedString(@"Photo access is restricted on this device. Please check your settings.", @"Message of an alert when the application is not authorized to access photo data.")];
    } else if (ALAuthorizationStatusAuthorized == authorizationStatus) {
        if (completion) {
            completion(YES);
        }
        return;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:HPPRLocalizedString(@"Photo Access Required", @"Title of an alert when the user has denied the permission to access the Photos of the device")
                                        message:HPPRLocalizedString(@"To select a photo you must first authorize this app to access your photo library.", @"Message shown when the user tries to access the Photos of the device before the authorization was requested")
                                       delegate:self
                              cancelButtonTitle:HPPRLocalizedString(@"Cancel", @"Button caption")
                              otherButtonTitles:HPPRLocalizedString(@"Authorize", @"Button caption"), nil] show];
        });
    }
}

- (void)requestPhotoAccess
{
    ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (nil == group) {
            if (self.accessCompletion) {
                self.accessCompletion(YES);
            }
        }
    } failureBlock:^(NSError *error) {
        NSString *msgText = HPPRLocalizedString(@"Allow access in your Settings to print and save your photos.", @"Message of an alert when the user has denied the permission to access the Photos of the device");

        [self noAccessWithCaption:HPPRLocalizedString(@"Photo Access Required", @"Title of an alert when the user has denied the permission to access the Photos of the device")
                       andMessage:msgText];
    }];
}

- (void)noAccessWithCaption:(NSString *)caption andMessage:(NSString *)message
{
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (canOpenSettings) {
            [[[UIAlertView alloc] initWithTitle:caption
                                        message:message
                                       delegate:self
                              cancelButtonTitle:HPPRLocalizedString(@"Cancel", @"Button caption")
                              otherButtonTitles:HPPRLocalizedString(@"Settings", @"Button caption"), nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:caption
                                        message:message
                                       delegate:self
                              cancelButtonTitle:HPPRLocalizedString(@"OK", @"Button caption")
                              otherButtonTitles:nil] show];
        }
    });
}

- (void)openSettings
{
    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
    if (canOpenSettings) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (kCameraRollCancelButtonIndex == buttonIndex) {
        if (self.accessCompletion) {
            self.accessCompletion(NO);
        }
    } else if ([HPPRLocalizedString(@"Settings", nil) isEqualToString:[alertView buttonTitleAtIndex:buttonIndex]]) {
        [self openSettings];
    } else {
        [self requestPhotoAccess];
    }
}

@end
