//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPBTSprocket.h"

@interface MPBTSprocket (Protected)

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)image targetSize:(CGSize)targetSize;
- (NSString *)supportedProtocolString:(EAAccessory *)accessory;

+ (void)latestFirmwareVersion:(NSString *)protocolString forExistingVersion:(NSUInteger)existingFwVersion completion:(void (^)(NSUInteger fwVersion))completion;
+ (void)latestFirmwarePath:(NSString *)protocolString forExistingVersion:(NSUInteger)existingFwVersion completion:(void (^)(NSString *fwPath))completion;

+ (NSString *)printModeString:(SprocketPrintMode)mode;
+ (NSString *)autoExposureString:(SprocketAutoExposure)exp;
+ (NSString *)dataClassificationString:(SprocketDataClassification)class;
+ (NSString *)upgradeStatusString:(SprocketUpgradeStatus)status;

@end
