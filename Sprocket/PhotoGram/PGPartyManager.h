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

#import <CoreBluetooth/CoreBluetooth.h>

@interface PGPartyManager : NSObject

extern NSString * const kPGPartyManagerServiceUUID;
extern NSString * const kPGPartyManagerCharacteristicUUID;
extern NSString * const kPGPartyManagerPartyModeEnabledNotification;

typedef NS_ENUM(NSInteger, PGPartyManagerErrorCode) {
    PGPartyManagerErrorBluetoothUnsupported = 1000,
    PGPartyManagerErrorBluetoothUnauthorized
};

- (NSString *)bluetoothState:(NSInteger)code;

+ (BOOL)isPartyModeEnabled;
+ (void)setPartyModeEnabled:(BOOL)enabled;

+ (BOOL)isPartySaveEnabled;
+ (void)setPartySaveEnabled:(BOOL)enabled;

+ (BOOL)isPartyPrintEnabled;
+ (void)setPartyPrintEnabled:(BOOL)enabled;

@end
