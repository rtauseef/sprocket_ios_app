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

#import "MPBTSprocket+Protected.h"
#import "NSBundle+MPLocalizable.h"
#import "MPBTMaui.h"
#import "MPBTManta.h"

NSString *kPGSettingsForceFirmwareUpgrade = @"kPGSettingsForceFirmwareUpgrade";
NSString *kPGUseExperimentalFirmware = @"kPGUseExperimentalFirmware";

static MPBTSprocket *currentInstance = nil;

@implementation MPBTSprocket

+ (MPBTSprocket *)sharedInstance
{
    if ( nil == currentInstance ) {
        currentInstance = [[MPBTSprocket alloc] init];
    }
    
    return currentInstance;
}

- (void)setAccessory:(EAAccessory *)accessory
{
    // need to bypass setter... avoids infinite loop within this function
    currentInstance->_accessory = nil;
    [currentInstance stopListeningToDeviceSession];
    currentInstance = nil;
    
    if ([[MPBTMaui sharedInstance] supportedProtocolString:accessory]) {
        currentInstance = [MPBTMaui sharedInstance];
        currentInstance.protocolString = [[MPBTMaui sharedInstance] supportedProtocolString:accessory];
    } else {
        if ([[MPBTManta sharedInstance] supportedProtocolString:accessory]) {
            currentInstance = [MPBTManta sharedInstance];
            currentInstance.protocolString = [[MPBTManta sharedInstance] supportedProtocolString:accessory];
        }
    }
    
    if( currentInstance ) {
        // need to bypass setter... avoids infinite loop within this function
        currentInstance->_accessory = accessory;
        [currentInstance listenToDeviceSession];
    } else {
        MPLogError(@"Unsupported device");
    }
}

- (void)printImage:(UIImage *)image numCopies:(NSInteger)numCopies
{
    NSAssert(FALSE, @"Need to implement printImage:numCopies:");
}

- (void)printItem:(MPPrintItem *)printItem numCopies:(NSInteger)numCopies
{
    NSAssert(FALSE, @"Need to implement printItem:numCopies:");
}

- (void)reflash
{
    NSAssert(FALSE, @"Need to implement reflash");
}

- (void)refreshInfo
{
    NSAssert(FALSE, @"Need to implement refreshInfo");
}

- (void)listenToDeviceSession
{
    NSAssert(FALSE, @"Need to implement listenToDeviceSession");
}

- (void)stopListeningToDeviceSession
{
    // do nothing... do not assert
}

+ (BOOL)forceFirmwareUpdates
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kPGSettingsForceFirmwareUpgrade];
}

+ (void)setForceFirmwareUpdates:(BOOL)force
{
    [[NSUserDefaults standardUserDefaults] setBool:force forKey:kPGSettingsForceFirmwareUpgrade];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) useExperimentalFirmware
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kPGUseExperimentalFirmware];
}

+ (void) setUseExperimentalFirmware:(BOOL)useExperimental
{
    [[NSUserDefaults standardUserDefaults] setBool:useExperimental forKey:kPGUseExperimentalFirmware];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Constant Helpers

+ (BOOL)supportedAccessory:(EAAccessory *)accessory
{
    NSString *protocolString = [[MPBTMaui sharedInstance] supportedProtocolString:accessory];
    if (nil == protocolString) {
        protocolString = [[MPBTManta sharedInstance] supportedProtocolString:accessory];
    }
    
    return (nil != protocolString);
}

+ (NSArray *)pairedSprockets
{
    NSArray *accs = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    NSMutableArray *pairedDevices = [[NSMutableArray alloc] init];
    
    for (EAAccessory *accessory in accs) {
        if ([MPBTSprocket supportedAccessory:accessory]) {
            [pairedDevices addObject:accessory];
        }
    }
    
    return pairedDevices;
}

+ (NSString *)macAddress:(NSData *)data
{
    NSUInteger dataLength = [data length];
    NSMutableString *string = [NSMutableString stringWithCapacity:dataLength*3 - 1];
    const unsigned char *dataBytes = [data bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [string appendFormat:@"%02x", dataBytes[idx]];
        if (idx+1 != dataLength) {
            [string appendString:@":"];
        }
    }
    
    return string;
}

+ (NSString *)version:(NSUInteger)version
{
    NSUInteger fw1, fw2, fw3;
    
    fw1 = (0xFF0000 & version) >> 16;
    fw2 = (0x00FF00 & version) >>  8;
    fw3 =  0x0000FF & version;
    
    return [NSString stringWithFormat:@"%lu.%lu.%lu", (unsigned long)fw1, (unsigned long)fw2, (unsigned long)fw3];
}

+ (NSString *)displayNameForAccessory:(EAAccessory *)accessory
{
    NSString *name = accessory.name;
    if ([name isEqualToString:@"HP Sprocket Photo Printer"]) {
        name = @"HP sprocket";
    }
    return [NSString stringWithFormat:@"%@ (%@)", name, accessory.serialNumber];
}

+ (NSString *)autoPowerOffIntervalString:(SprocketAutoPowerOffInterval)interval
{
    NSString *intervalString;
    
    switch (interval) {
        case SprocketAutoOffThreeMin:
            intervalString = MPLocalizedString(@"3 minutes", @"The printer will shut off after 3 minutes");
            break;
        case SprocketAutoOffFiveMin:
            intervalString = MPLocalizedString(@"5 minutes", @"The printer will shut off after 5 minutes");
            break;
        case SprocketAutoOffTenMin:
            intervalString = MPLocalizedString(@"10 minutes", @"The printer will shut off after 10 minutes");
            break;
        case SprocketAutoOffAlwaysOn:
            intervalString = MPLocalizedString(@"Always On", @"The printer will never shut off");
            break;
            
        default:
            intervalString = [NSString stringWithFormat:@"Unrecognized interval: %d", interval];
            break;
    };
    
    return intervalString;
}

+ (NSString *)errorTitleKey:(SprocketError)error
{
    NSString *errString;
    
    switch (error) {
        case SprocketErrorNoError:
            errString = @"Ready";
            break;
        case SprocketErrorBusy:
            errString = @"Sprocket Printer in Use";
            break;
        case SprocketErrorPaperJam:
            errString = @"Paper has Jammed";
            break;
        case SprocketErrorPaperEmpty:
            errString = @"Out of Paper";
            break;
        case SprocketErrorPaperMismatch:
            errString = @"Incorrect Paper Type";
            break;
        case SprocketErrorDataError:
            errString = @"Error Sending Image";
            break;
        case SprocketErrorCoverOpen:
            errString = @"Paper Cover Open";
            break;
        case SprocketErrorSystemError:
            errString = @"System Error Occured";
            break;
        case SprocketErrorBatteryLow:
            errString = @"Battery Low";
            break;
        case SprocketErrorBatteryFault:
            errString = @"Battery Error";
            break;
        case SprocketErrorHighTemperature:
            errString = @"Sprocket is Warm";
            break;
        case SprocketErrorLowTemperature:
            errString = @"Sprocket is Cold";
            break;
        case SprocketErrorCoolingMode:
            errString = @"Cooling Down...";
            break;
        case SprocketErrorWrongCustomer:
            errString = @"Error";
            break;
        case SprocketErrorNoSession:
            errString = @"Sprocket Printer Not Connected";
            break;
            
        default:
            errString = @"Unrecognized Error";
            break;
    };
    
    return errString;
}

+ (NSString *)errorTitle:(SprocketError)error
{
    NSString *errString;
    
    switch (error) {
        case SprocketErrorNoError:
            errString = MPLocalizedString(@"Ready", @"Message given when sprocket has no known error");
            break;
        case SprocketErrorNoSession:
        case SprocketErrorBusy:
            errString = MPLocalizedString(@"Sprocket Printer in Use", @"Message given when sprocket cannot print due to being in use.");
            break;
        case SprocketErrorPaperJam:
            errString = MPLocalizedString(@"Paper has Jammed", @"Message given when sprocket cannot print due to having a paper jam");
            break;
        case SprocketErrorPaperEmpty:
            errString = MPLocalizedString(@"Out of Paper", @"Message given when sprocket cannot print due to having no paper");
            break;
        case SprocketErrorPaperMismatch:
            errString = MPLocalizedString(@"Incorrect Paper Type", @"Message given when sprocket cannot print due to being loaded with the wrong kind of paper");
            break;
        case SprocketErrorDataError:
            errString = MPLocalizedString(@"Error Sending Image", @"Message given when sprocket cannot print due to an error with the image data.");
            break;
        case SprocketErrorCoverOpen:
            errString = MPLocalizedString(@"Paper Cover Open", @"Message given when sprocket cannot print due to the cover being open");
            break;
        case SprocketErrorSystemError:
            errString = MPLocalizedString(@"System Error Occured", @"Message given when sprocket cannot print due to a system error");
            break;
        case SprocketErrorBatteryLow:
            errString = MPLocalizedString(@"Battery Low", @"Message given when sprocket cannot print due to having a low battery");;
            break;
        case SprocketErrorBatteryFault:
            errString = MPLocalizedString(@"Battery Error", @"Message given when sprocket cannot print due to having an error related to the battery.");
            break;
        case SprocketErrorHighTemperature:
            errString = MPLocalizedString(@"Sprocket is Warm", @"Message given when sprocket cannot print due to being too hot");
            break;
        case SprocketErrorLowTemperature:
            errString = MPLocalizedString(@"Sprocket is Cold", @"Message given when sprocket cannot print due to being too cold");
            break;
        case SprocketErrorCoolingMode:
            errString = MPLocalizedString(@"Cooling Down...", @"Message given when sprocket cannot print due to bing in a cooling mode");
            break;
        case SprocketErrorWrongCustomer:
            errString = MPLocalizedString(@"Error", @"Message given when sprocket cannot print due to not recognizing data from our app");
            break;
            
        default:
            errString = MPLocalizedString(@"Unrecognized Error", @"Message given when sprocket has an unrecgonized error");
            break;
    };
    
    return errString;
}

+ (NSString *)errorDescription:(SprocketError)error
{
    NSString *errString;
    
    switch (error) {
        case SprocketErrorNoError:
            errString = MPLocalizedString(@"Sprocket is ready to print.", @"Message given when sprocket has no known error");
            break;
        case SprocketErrorNoSession:
        case SprocketErrorBusy:
            errString = MPLocalizedString(@"Sprocket is already processing an image. Please wait to send more.", @"Message given when sprocket cannot print due to being in use.");
            break;
        case SprocketErrorPaperJam:
            errString = MPLocalizedString(@"Clear paper jam and restart the printer by pressing and holding the power button.", @"Message given when sprocket cannot print due to having a paper jam");
            break;
        case SprocketErrorPaperEmpty:
            errString = MPLocalizedString(@"Load paper with the included Smartsheet to continue printing.", @"Message given when sprocket cannot print due to having no paper");
            break;
        case SprocketErrorPaperMismatch:
            errString = MPLocalizedString(@"Use HP branded ZINK Photo Paper. Load the Smartsheet, barcode down.", @"Message given when sprocket cannot print due to being loaded with the wrong kind of paper");
            break;
        case SprocketErrorDataError:
            errString = MPLocalizedString(@"There was an error while sending your image to the printer.", @"Message given when sprocket cannot print due to an error with the image data.");
            break;
        case SprocketErrorCoverOpen:
            errString = MPLocalizedString(@"Close the cover to proceed.", @"Message given when sprocket cannot print due to the cover being open");
            break;
        case SprocketErrorSystemError:
            errString = MPLocalizedString(@"Due to a system error, restart sprocket to continue printing.", @"Message given when sprocket cannot print due to a system error");
            break;
        case SprocketErrorBatteryLow:
            errString = MPLocalizedString(@"Connect your sprocket to a power source to continue use.", @"Message given when sprocket cannot print due to having a low battery");
            break;
        case SprocketErrorBatteryFault:
            errString = MPLocalizedString(@"A battery error has occured. Restart Sprocket to continue printing.", @"Message given when sprocket cannot print due to having an error related to the battery.");
            break;
        case SprocketErrorHighTemperature:
            errString = MPLocalizedString(@"Printing will resume after your Sprocket cools down.", @"Message given when sprocket cannot print due to being too hot");
            break;
        case SprocketErrorLowTemperature:
            errString = MPLocalizedString(@"Printing will resume after your Sprocket warms up.", @"Message given when sprocket cannot print due to being too cold");
            break;
        case SprocketErrorCoolingMode:
            errString = MPLocalizedString(@"Printing will resume after your Sprocket cools down.", @"Message given when sprocket cannot print due to bing in a cooling mode");
            break;
        case SprocketErrorWrongCustomer:
            errString = MPLocalizedString(@"The device is not recognized.", @"Message given when sprocket cannot print due to not recognizing data from our app");
            break;
            
        default:
            errString = MPLocalizedString(@"Unrecognized Error", @"Message given when sprocket has an unrecgonized error");
            break;
    };
    
    return errString;
}

@end
