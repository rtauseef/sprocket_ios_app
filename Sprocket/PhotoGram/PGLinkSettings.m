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

#import "PGLinkSettings.h"

NSString * const kPGLinkSettingsEnabled = @"kPGLinkSettingsEnabled";
NSString * const kPGLinkSettingsChangedNotification = @"kPGLinkSettingsChangedNotification";
static NSString * const kPGLinkSettingsVideoPrintEnabled = @"kPGVideoPrintEnabled";
static NSString * const kPGLinkSettingsFakePrintEnabled = @"kPGFakePrintEnabled";
static NSString * const kPGLinkSettingsLocalWatermarkEnabled = @"kPGLocalWatermarkEnabled";
static NSString * const kPGLinkSettingsVideoAREnabled = @"kPGVideoAREnabled";

@implementation PGLinkSettings

+ (void)setLinkEnabled:(BOOL)visible {
    [[NSUserDefaults standardUserDefaults] setObject:@(visible) forKey:kPGLinkSettingsEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGLinkSettingsChangedNotification object:self];
    });
}

+ (BOOL)linkEnabled {
    NSNumber *visible = [[NSUserDefaults standardUserDefaults] objectForKey:kPGLinkSettingsEnabled];
    return visible ? visible.boolValue : NO;
}

+ (void)setVideoPrintEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kPGLinkSettingsVideoPrintEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPGLinkSettingsChangedNotification object:self];
}

+ (BOOL)videoPrintEnabled {
    NSNumber * enabled = [[NSUserDefaults standardUserDefaults] objectForKey:kPGLinkSettingsVideoPrintEnabled];
    return enabled && enabled.boolValue;
}

+ (void)setFakePrintEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kPGLinkSettingsFakePrintEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPGLinkSettingsChangedNotification object:self];
}

+ (BOOL)fakePrintEnabled {
    NSNumber * enabled = [[NSUserDefaults standardUserDefaults] objectForKey:kPGLinkSettingsFakePrintEnabled];
    return enabled && enabled.boolValue;
}

+ (BOOL)localWatermarkEnabled {
    NSNumber * enabled = [[NSUserDefaults standardUserDefaults] objectForKey:kPGLinkSettingsLocalWatermarkEnabled];
    return enabled && enabled.boolValue;
}

+ (void)setLocalWatermarkEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kPGLinkSettingsLocalWatermarkEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPGLinkSettingsLocalWatermarkEnabled object:self];
}

+ (BOOL)videoAREnabled {
    NSNumber * enabled = [[NSUserDefaults standardUserDefaults] objectForKey:kPGLinkSettingsVideoAREnabled];
    return enabled && enabled.boolValue;
}

+ (void)setVideoAREnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kPGLinkSettingsVideoAREnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPGLinkSettingsVideoAREnabled object:self];
}

@end
