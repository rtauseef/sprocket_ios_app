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

#import "PGPartyManager.h"

@implementation PGPartyManager

NSString * const kPGPartyManagerServiceUUID = @"3605946E-9BBB-4366-9369-06B7D4412927";
NSString * const kPGPartyManagerCharacteristicUUID = @"A2C300D2-72CF-4B17-BD4A-6C0BDFE28DAC";

- (NSString *)bluetoothState:(NSInteger)code
{
    switch (code) {
        case CBManagerStateUnknown:
            return  @"Unknown";
        case CBManagerStateResetting:
            return @"Resetting";
        case CBManagerStateUnsupported:
            return @"Unsupported";
        case CBManagerStateUnauthorized:
            return @"Unauthorized";
        case CBManagerStatePoweredOff:
            return @"Powered Off";
        case CBManagerStatePoweredOn:
            return @"Powered On";
    }
    
    return @"Undefined";
}

@end
