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

@interface PGFeatureFlag : NSObject

extern NSString * const kPGFeatureFlagPartyModeEnabledNotification;

+ (BOOL)isMultiPrintEnabled;

+ (BOOL)isCloudAssetsEnabled;
+ (void)setCloudAssetsEnabled:(BOOL)enabled;

+ (BOOL)isPartyModeEnabled;
+ (void)setPartyModeEnabled:(BOOL)enabled;

+ (BOOL)isPartySaveEnabled;
+ (void)setPartySaveEnabled:(BOOL)enabled;

+ (BOOL)isPartyPrintEnabled;
+ (void)setPartyPrintEnabled:(BOOL)enabled;

@end
