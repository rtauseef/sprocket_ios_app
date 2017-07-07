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

@implementation PGFeatureFlag

+ (BOOL)isMultiPrintEnabled
{
    return YES;
}

+ (void)setCloudAssetsEnabled:(BOOL)enabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setBool:enabled forKey:kEnableCloudAssetsKey];
    [userDefaults synchronize];
}

+ (BOOL)isCloudAssetsEnabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    return [userDefaults boolForKey:kEnableCloudAssetsKey];
}

@end
