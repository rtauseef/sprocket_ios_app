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

static NSString * const kEnableMultiPrintKey = @"com.hp.hp-sprocket.enableMultiPrint";

@implementation PGFeatureFlag

+ (void)setMultiPrintEnabled:(BOOL)enabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setBool:enabled forKey:kEnableMultiPrintKey];
    [userDefaults synchronize];
}

+ (BOOL)isMultiPrintEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    return [userDefaults boolForKey:kEnableMultiPrintKey];
}

@end
