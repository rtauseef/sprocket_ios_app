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

#import "PGFeatureFlag.h"

static NSString * const kEnableCloudAssetsKey = @"com.hp.hp-sprocket.enableCloudAssets";
static NSString * const kPartyModeEnabledKey = @"com.hp.sprocket.key.party.mode.enabled";
static NSString * const kPartySaveEnabledKey = @"com.hp.sprocket.key.party.save.enabled";
static NSString * const kPartyPrintEnabledKey = @"com.hp.sprocket.key.party.print.enabled";

NSString * const kPGFeatureFlagPartyModeEnabledNotification = @"com.hp.sprocket.notification.party.mode.enabled";

@implementation PGFeatureFlag

#pragma mark - Flags

+ (BOOL)isMultiPrintEnabled
{
    return YES;
}

+ (BOOL)isCloudAssetsEnabled
{
    return [self getFlag:kEnableCloudAssetsKey];
}

+ (void)setCloudAssetsEnabled:(BOOL)enabled
{
    [self setFlag:kEnableCloudAssetsKey enabled:enabled];
}

+ (BOOL)isPartyModeEnabled {
    return [self getFlag:kPartyModeEnabledKey];
}

+ (void)setPartyModeEnabled:(BOOL)enabled {
    [self setFlag:kPartyModeEnabledKey enabled:enabled notification:kPGFeatureFlagPartyModeEnabledNotification];
}

+ (BOOL)isPartySaveEnabled {
    return [self getFlag:kPartySaveEnabledKey];
}

+ (void)setPartySaveEnabled:(BOOL)enabled {
    [self setFlag:kPartySaveEnabledKey enabled:enabled];
}

+ (BOOL)isPartyPrintEnabled {
    return [self getFlag:kPartyPrintEnabledKey];
}

+ (void)setPartyPrintEnabled:(BOOL)enabled {
    [self setFlag:kPartyPrintEnabledKey enabled:enabled];
}

#pragma mark - Helpers

+ (void)setFlag:(NSString *)key enabled:(BOOL)enabled
{
    [self setFlag:key enabled:enabled notification:nil];
}

+ (void)setFlag:(NSString *)key enabled:(BOOL)enabled notification:(NSString * _Nullable)notification
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (nil != notification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self];
    }
}

+ (BOOL)getFlag:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

@end
