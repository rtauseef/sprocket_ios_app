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

#ifndef MPBTSprocketDefinitions_h
#define MPBTSprocketDefinitions_h

static const NSString *kPolaroidProtocol = @"com.polaroid.snapprinter";

typedef enum {
    SprocketAutoExposureOff = 0x00,
    SprocketAutoExposureOn  = 0x01
} SprocketAutoExposure;

typedef enum {
    SprocketAutoOffThreeMin  = 0x04,
    SprocketAutoOffFiveMin   = 0x08,
    SprocketAutoOffTenMin    = 0x0C,
    SprocketAutoOffAlwaysOn  = 0x00
} SprocketAutoPowerOffInterval;

typedef enum {
    SprocketPrintModePaperFull = 0x01,
    SprocketPrintModeImageFull = 0x02
} SprocketPrintMode;

typedef enum {
    SprocketDataClassImage    = 0x00,
    SprocketDataClassTMD      = 0x01,
    SprocketDataClassFirmware = 0x02
} SprocketDataClassification;

typedef enum {
    SprocketUpgradeStatusStart  = 0x00,
    SprocketUpgradeStatusFinish = 0x01,
    SprocketUpgradeStatusFail   = 0x02,
    SprocketUpgradeStatusDownloadFail = 0x0100
} SprocketUpgradeStatus;

typedef enum {
    SprocketErrorNoError         = 0x00,
    SprocketErrorBusy            = 0x01,
    SprocketErrorPaperJam        = 0x02,
    SprocketErrorPaperEmpty      = 0x03,
    SprocketErrorPaperMismatch   = 0x04,
    SprocketErrorDataError       = 0x05,
    SprocketErrorCoverOpen       = 0x06,
    SprocketErrorSystemError     = 0x07,
    SprocketErrorBatteryLow      = 0x08,
    SprocketErrorBatteryFault    = 0x09,
    SprocketErrorHighTemperature = 0x0A,
    SprocketErrorLowTemperature  = 0x0B,
    SprocketErrorCoolingMode     = 0x0C,
    // Cancel is for Android only
    SprocketErrorWrongCustomer   = 0x0E,
    SprocketErrorNoSession       = 0xFF00,
} SprocketError;

#endif /* MPBTSprocketDefinitions_h */
