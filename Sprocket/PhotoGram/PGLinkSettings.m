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

@implementation PGLinkSettings

+ (void)setLinkEnabled:(BOOL)visible {
    [[NSUserDefaults standardUserDefaults] setObject:@(visible) forKey:kPGLinkSettingsEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // TODO:jbt: get this working
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPGLinkSettingsChangedNotification object:self];
    });
}

+ (BOOL)linkEnabled {
    NSNumber *visible = [[NSUserDefaults standardUserDefaults] objectForKey:kPGLinkSettingsEnabled];
    return visible ? visible.boolValue : NO;
}

@end
