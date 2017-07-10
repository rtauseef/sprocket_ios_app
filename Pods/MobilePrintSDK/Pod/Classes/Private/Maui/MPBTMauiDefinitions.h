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

#ifndef MPBTMauiDefinitions_h
#define MPBTMauiDefinitions_h


typedef enum {
    MauiDataClassImage       = 0x00,
    MauiDataClassCnx         = 0x01,
    MauiDataClassFirmware    = 0x02,
    MauiDataClassUpgrade     = 0x0B,
    MauiDataClassTmd         = 0x0C,
    MauiDataClassCameraParam = 0x0D
} MauiDataClassification;

typedef enum {
    MauiUpgradeDataClassFirmware = 0x00,
    MauiUpgradeDataClassCnx      = 0x01,
    MauiUpgradeDataClassTmd      = 0x02,
    MauiUpgradeDataClassFwCnx    = 0x03,
    MauiUpgradeDataClassFwTmd    = 0x04,
    MauiUpgradeDataClassCnxTmd   = 0x05,
    MauiUpgradeDataClassAll      = 0x06
} MauiUpgradeDataClass;

typedef enum {
    MauiPrintingPercentage25 = 0x01,
    MauiPrintingPercentage50 = 0x02,
    MauiPrintingPercentage75 = 0x03
} MauiPrintingPercentage;

typedef enum {
    MauiAutoOffThreeMin  = 0x00,
    MauiAutoOffFiveMin   = 0x01,
    MauiAutoOffTenMin    = 0x02,
    MauiAutoOffAlwaysOn  = 0x03
} MauiAutoPowerOffInterval;

typedef enum {
    MauiBatteryStatus5   = 0x00,
    MauiBatteryStatus25  = 0x01,
    MauiBatteryStatus50  = 0x02,
    MauiBatteryStatus75  = 0x03,
    MauiBatteryStatus100 = 0x04
} MauiBatteryStatus;

typedef enum {
    MauiPrintModeImageFull = 0x00,
    MauiPrintModePaperFull = 0x01
} MauiPrintMode;

typedef enum {
    MauiUpgradeStatusStart  = 0x00,
    MauiUpgradeStatusFinish = 0x01,
    MauiUpgradeStatusFail   = 0x02,
    MauiUpgradeStatusDownloadFail = 0x0100
} MauiUpgradeStatus;

typedef enum {
    MauiErrorNoError         = 0x00,
    MauiErrorBusy            = 0x01,
    MauiErrorPaperJam        = 0x02,
    MauiErrorPaperEmpty      = 0x03,
    MauiErrorPaperMismatch   = 0x04,
    MauiErrorDataError       = 0x05,
    MauiErrorCoverOpen       = 0x06,
    MauiErrorSystemError     = 0x07,
    MauiErrorBatteryLow      = 0x08,
    MauiErrorBatteryFault    = 0x09,
    MauiErrorHighTemperature = 0x0A,
    MauiErrorLowTemperature  = 0x0B,
    MauiErrorCoolingMode     = 0x0C,
    // Cancel is for Android only
    MauiErrorWrongCustomer   = 0x0E,
    MauiErrorNoSession       = 0xFF00,
} MauiError;


#endif /* MauiDefinitions_h */
