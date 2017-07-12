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

#import "MPBTMaui.h"
#import "MPBTSessionController.h"
#import "MPPrintItemImage.h"
#import "NSBundle+MPLocalizable.h"
#import "MP.h"

const char MAUI_PACKET_LENGTH = 34;

static const NSString *kPolaroidSnapProtocol = @"com.polaroid.snapprinter";
static const NSString *kHpMauiProtocol = @"com.hp.protocol.maui";

static const NSString *kMPBTFirmwareVersionKey = @"fw_version";
static const NSString *kMPBTTmdVersionKey = @"tmd_version";
static const NSString *kMPBTModelNumberKey = @"model_number";
static const NSString *kMPBTHardwareVersion = @"hw_version";

// Common to all packets
static const char START_CODE_BYTE_1    = 0x1B;
static const char START_CODE_BYTE_2    = 0x2A;
static const char POLAROID_CUSTOMER_CODE_BYTE_1 = 0x43;
static const char POLAROID_CUSTOMER_CODE_BYTE_2 = 0x41;
static const char HP_CUSTOMER_CODE_BYTE_1 = 0x48;
static const char HP_CUSTOMER_CODE_BYTE_2 = 0x50;

// Commands
static const char CMD_PRINT_READY_CMD       = 0x00;
static const char CMD_PRINT_READY_SUB_CMD   = 0x00;

static const char CMD_UPGRADE_READY_CMD              = 0x02;
static const char CMD_UPGRADE_READY_SUB_CMD_FIRMWARE = 0x00;
static const char CMD_UPGRADE_READY_SUB_CMD_CNX      = 0x01;
static const char CMD_UPGRADE_READY_SUB_CMD_TMD      = 0x02;

static const char CMD_TMD_VERSION_CMD       = 0x02;
static const char CMD_TMD_VERSION_SUB_CMD   = 0x04;

static const char CMD_UPGRADE_CMD           = 0x02;
static const char CMD_UPGRADE_SUB_CMD       = 0x06;

static const char CMD_GET_INFO_CMD          = 0x07;
static const char CMD_GET_INFO_SUB_CMD      = 0x00;

static const char CMD_SET_INFO_CMD                = 0x06;
static const char CMD_SET_INFO_POWER_OFF_SUB_CMD  = 0x00;
static const char CMD_SET_INFO_SOUND_SUB_CMD      = 0x01;
static const char CMD_SET_INFO_FLASH_SUB_CMD      = 0x02;
static const char CMD_SET_INFO_PRINT_MODE_SUB_CMD = 0x03;
static const char CMD_SET_INFO_BORN_ON_SUB_CMD    = 0x04;


// Responses
static const char RESP_PRINT_START_CMD            = 0x00;
static const char RESP_PRINT_START_SUB_CMD        = 0x02;

static const char RESP_PRINT_FINISH_CMD           = 0x00;
static const char RESP_PRINT_FINISH_SUB_CMD       = 0x03;

static const char RESP_START_OF_SEND_ACK_CMD      = 0x01;
static const char RESP_START_OF_SEND_ACK_SUB_CMD  = 0x00;

static const char RESP_END_OF_RECEIVE_ACK_CMD     = 0x01;
static const char RESP_END_OF_RECEIVE_ACK_SUB_CMD = 0x01;

static const char RESP_TMD_VERSION_CMD            = 0x02;
static const char RESP_TMD_VERSION_SUB_CMD        = 0x05;

static const char RESP_ERROR_MESSAGE_ACK_CMD      = 0x04;
static const char RESP_ERROR_MESSAGE_ACK_SUB_CMD  = 0x00;

static const char RESP_PRINT_PERCENTAGE_CMD       = 0x05;
static const char RESP_PRINT_PERCENTAGE_SUB_CMD   = 0x00;

static const char RESP_GET_INFO_CMD               = 0x07;
static const char RESP_GET_INFO_SUB_CMD           = 0x00;

static const char RESP_SET_INFO_CMD               = 0x06;
static const char RESP_SET_INFO_SUB_CMD           = 0x01;

@import UIKit;

@interface MPBTMaui () <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) MPBTSessionController *session;
@property (strong, nonatomic) NSData* imageData;
@property (strong, nonatomic) NSData* upgradeData;
@property (strong, nonatomic) NSArray *supportedProtocols;
@property (assign, nonatomic, readonly) NSUInteger batteryLevel;
@property (assign, nonatomic) MauiAutoPowerOffInterval localPowerOffInterval;
@property (assign, nonatomic) MauiPrintMode localPrintMode;

@end

@implementation MPBTMaui

#pragma mark - Public methods

+ (MPBTMaui *)sharedInstance
{
    static MPBTMaui *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MPBTMaui alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.supportedProtocols = @[kHpMauiProtocol, kPolaroidSnapProtocol/*, @"com.lge.pocketphoto"*/];
    }
    
    return self;
}

- (void)listenToDeviceSession
{
    // watch for received data from the accessory
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:MPBTSessionDataReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataSent:) name:MPBTSessionDataSentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:MPBTSessionAccessoryDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionStreamError:) name:MPBTSessionStreamErrorNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
}

- (void)stopListeningToDeviceSession
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshInfo
{
    [self.session writeData:[self accessoryInfoRequest]];
}

- (void)printImage:(UIImage *)image numCopies:(NSInteger)numCopies
{
    UIImage *scaledImage = [self imageByScalingAndCroppingForSize:image targetSize:CGSizeMake(640,960)];
    self.imageData = UIImageJPEGRepresentation(scaledImage, 0.9);
    
    [self.session writeData:[self printReadyRequest:numCopies]];
}

- (void)printItem:(MPPrintItem *)printItem numCopies:(NSInteger)numCopies
{
    UIImage *asset = ((NSArray*)printItem.printAsset)[0];
    UIImage *image = [self imageByScalingAndCroppingForSize:asset targetSize:CGSizeMake(640,960)];
    self.imageData = UIImageJPEGRepresentation(image, 0.9);
    
    [self.session writeData:[self printReadyRequest:numCopies]];
}

- (void)reflash
{
    //    [self.session writeData:[self tmdVersionRequest]];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    MPLogDebug(@"Resuming firmware download");
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    MPLogDebug(@"%lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didDownloadDeviceUpgradeData:percentageComplete:)]) {
        NSInteger percentageComplete = ((float)totalBytesWritten/(float)totalBytesExpectedToWrite) * 100;
        [self.delegate didDownloadDeviceUpgradeData:self percentageComplete:percentageComplete];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    MPLogInfo(@"Finished downloading firmware");
    self.upgradeData = [NSData dataWithContentsOfURL:location];
    [self.session writeData:[self upgradeReadyRequest]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (nil != error) {
        MPLogError(@"Error receiving firmware upgrade file: %@", error);
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
            [self.delegate didChangeDeviceUpgradeStatus:self status:SprocketUpgradeStatusDownloadFail];
        }
    }
}

#pragma mark - Getters/Setters

- (MPBTSessionController *)session
{
    _session = nil;
    
    if (self.accessory) {
        _session = [MPBTSessionController sharedController];
        [_session setupControllerForAccessory:self.accessory
                           withProtocolString:self.protocolString];
        
        BOOL success = [_session openSession];
        if (!success) {
            MPLogError(@"Failed to open session with device");
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didReceiveError:error:)]) {
                [self.delegate didReceiveError:self error:SprocketErrorNoSession];
            }
        }
    } else {
        MPLogError(@"Can't open a session with a nil device / accessory");
    }
    
    return _session;
}

- (void)setPowerOffInterval:(SprocketAutoPowerOffInterval)powerOffInterval
{
    MauiAutoPowerOffInterval newInterval = [MPBTMaui mauiPowerOffIntervalForSprocketPowerOffInterval:powerOffInterval];
    
    if (self.localPowerOffInterval != newInterval) {
        self.localPowerOffInterval = newInterval;
        [self.session writeData:[self setPowerOffRequest]];
    }
}

- (SprocketAutoPowerOffInterval)powerOffInterval
{
    return [MPBTMaui sprocketPowerOffIntervalForMauiPowerOffInterval:self.localPowerOffInterval];
}

- (void)setPrintMode:(SprocketPrintMode)printMode
{
    MauiPrintMode newPrintMode = [MPBTMaui mauiPrintModeForSprocketPrintMode:printMode];
    
    if (self.localPrintMode != newPrintMode) {
        self.localPrintMode = newPrintMode;
        [self.session writeData:[self setPrintModeRequest]];
    }
}

- (SprocketPrintMode):printMode
{
    return [MPBTMaui sprocketPrintModeForMauiPrintMode:self.localPrintMode];
}

- (NSString *)displayName
{
    return [MPBTMaui displayNameForAccessory:self.accessory];
}

- (NSUInteger)batteryStatus {
    NSUInteger status = 0;
    
    switch (_batteryLevel) {
        case 0:
            status = 5;
            break;
        case 1:
            status = 25;
            break;
        case 2:
            status = 50;
            break;
        case 3:
            status = 75;
            break;
        case 4:
            status = 100;
            break;
    };
    
    return status;
}

- (NSDictionary *)analytics
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setValue:[MPBTMaui macAddress:self.macAddress] forKey:kMPPrinterId];
    [dictionary setValue:[MPBTMaui displayNameForAccessory:self.accessory] forKey:kMPPrinterDisplayName];
    [dictionary setValue:[NSString stringWithFormat:@"HP sprocket"] forKey:kMPPrinterMakeAndModel];
    
    NSString *fwVersion  = [MPBTMaui version:self.firmwareVersion] ? [MPBTMaui version:self.firmwareVersion] : @"";
    NSString *tmdVersion = [MPBTMaui version:self.hardwareVersion] ? [MPBTMaui version:self.hardwareVersion] : @"";
    NSString *modelNum   = self.accessory.modelNumber ? self.accessory.modelNumber : @"";
    NSString *hwVersion  = self.accessory.hardwareRevision ? self.accessory.hardwareRevision : @"";
    
    NSDictionary *customData = @{ kMPBTFirmwareVersionKey : fwVersion,
                                  kMPBTTmdVersionKey      : tmdVersion,
                                  kMPBTModelNumberKey     : modelNum,
                                  kMPBTHardwareVersion    : hwVersion };
    [dictionary setValue:customData forKey:kMPCustomAnalyticsKey];
    
    return dictionary;
}

#pragma mark - Util

- (NSString *)supportedProtocolString:(EAAccessory *)accessory
{
    NSString *protocolString = nil;
    if (accessory) {
        
        for (NSString *protocol in [accessory protocolStrings]) {
            
            for (NSString *supportedProtocol in self.supportedProtocols) {
                if( [supportedProtocol isEqualToString:protocol] ) {
                    protocolString = supportedProtocol;
                }
            }
        }
    }
    
    return protocolString;
}

#pragma mark - Packet Creation

- (void)setupPacket:(char[MAUI_PACKET_LENGTH])packet command:(char)command subcommand:(char)subcommand
{
    memset(packet, 0, MAUI_PACKET_LENGTH);

    packet[0] = START_CODE_BYTE_1;
    packet[1] = START_CODE_BYTE_2;
    
    if ([self.protocolString isEqualToString:[kPolaroidSnapProtocol copy]]) {
        packet[2] = POLAROID_CUSTOMER_CODE_BYTE_1;
        packet[3] = POLAROID_CUSTOMER_CODE_BYTE_2;
    } else if ([self.protocolString isEqualToString:[kHpMauiProtocol copy]]){
        packet[2] = HP_CUSTOMER_CODE_BYTE_1;
        packet[3] = HP_CUSTOMER_CODE_BYTE_2;
    } else {
        MPLogError(@"Unexpected protocol string: %@, defaulting to HP customer code", self.protocolString);
        packet[2] = HP_CUSTOMER_CODE_BYTE_1;
        packet[3] = HP_CUSTOMER_CODE_BYTE_2;
    }
    
    packet[6] = command;
    packet[7] = subcommand;
}

- (NSData *)accessoryInfoRequest
{
    NSMutableData *data;
    char byteArray[MAUI_PACKET_LENGTH];

    [self setupPacket:byteArray command:CMD_GET_INFO_CMD subcommand:CMD_GET_INFO_SUB_CMD];

    data = [NSMutableData dataWithBytes:byteArray length:MAUI_PACKET_LENGTH];

    MPLogDebug(@"accessoryInfoRequest: %@", data);

    return data;
}

- (NSData *)printReadyRequest:(NSInteger)numCopies
{
    NSMutableData *data;
    char byteArray[MAUI_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_PRINT_READY_CMD subcommand:CMD_PRINT_READY_SUB_CMD];
    
    // imageSize
    NSUInteger imageSize = self.imageData.length;
    byteArray[8] = (0xFF0000 & imageSize) >> 16;
    byteArray[9] = (0x00FF00 & imageSize) >>  8;
    byteArray[10] = 0x0000FF & imageSize;
    
    // printCount... Maui capped the number of copies at 4
    byteArray[11] = numCopies <= 4 ? numCopies : 4;
    
    data = [NSMutableData dataWithBytes:byteArray length:MAUI_PACKET_LENGTH];
    
    MPLogDebug(@"printReadyRequest: %@", data);
    
    return data;
}

- (NSData *)upgradeReadyRequest
{
    NSMutableData *data;
    char byteArray[MAUI_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_UPGRADE_READY_CMD subcommand:CMD_UPGRADE_READY_SUB_CMD_FIRMWARE];
    
    // imageSize
    NSUInteger imageSize = self.upgradeData.length;
    byteArray[8] = (0xFF0000 & imageSize) >> 16;
    byteArray[9] = (0x00FF00 & imageSize) >>  8;
    byteArray[10] = 0x0000FF & imageSize;
    
    data = [NSMutableData dataWithBytes:byteArray length:MAUI_PACKET_LENGTH];
    
    MPLogDebug(@"upgradeReadyRequest: %@", data);

    return data;
}

- (NSData *)upgradeRequest
{
    NSMutableData *data;
    char byteArray[MAUI_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_UPGRADE_CMD subcommand:CMD_UPGRADE_SUB_CMD];
    
    data = [NSMutableData dataWithBytes:byteArray length:MAUI_PACKET_LENGTH];
    
    MPLogDebug(@"upgradeRequest: %@", data);
    
    return data;
}

- (NSData *)tmdVersionRequest
{
    NSMutableData *data;
    char byteArray[MAUI_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_TMD_VERSION_CMD subcommand:CMD_TMD_VERSION_SUB_CMD];
    
    data = [NSMutableData dataWithBytes:byteArray length:MAUI_PACKET_LENGTH];
    
    MPLogDebug(@"tmdVersionRequest: %@", data);
    
    return data;
}

- (NSData *)setPowerOffRequest
{
    NSMutableData *data;
    char byteArray[MAUI_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_SET_INFO_CMD subcommand:CMD_SET_INFO_POWER_OFF_SUB_CMD];
    
    byteArray[8]  = self.localPowerOffInterval;

    data = [NSMutableData dataWithBytes:byteArray length:MAUI_PACKET_LENGTH];
    
    MPLogDebug(@"setInfoRequest for Power Off Inteval: %@", data);

    return data;
}

- (NSData *)setPrintModeRequest
{
    NSMutableData *data;
    char byteArray[MAUI_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_SET_INFO_CMD subcommand:CMD_SET_INFO_PRINT_MODE_SUB_CMD];
    
    byteArray[8]  = self.localPrintMode;
    
    data = [NSMutableData dataWithBytes:byteArray length:MAUI_PACKET_LENGTH];
    
    MPLogDebug(@"setInfoRequest for Print Mode: %@", data);
    
    return data;
}

#pragma mark - Parsers

- (void)parseAccessoryInfo:(NSData *)payload
{
    char batteryStatus[]   = {0};
    char autoPowerOff[]    = {0};
    char sound[]           = {0};
    char flash[]           = {0};
    char printMode[]       = {0};
    char serialNum[]       = {0,0,0,0,0};
    char fwVer[]           = {0,0,0};
    char cnxVer[]          = {0,0};
    char tmdVer[]          = {0,0};
    char hwProductNum[]    = {0,0,0};
    
    // Note: maxPayloadSize is only available on Android... not forgotten here
    
    [payload getBytes:batteryStatus   range:NSMakeRange( 0,1)];
    [payload getBytes:autoPowerOff    range:NSMakeRange( 1,1)];
    [payload getBytes:sound           range:NSMakeRange( 2,1)];
    [payload getBytes:flash           range:NSMakeRange( 3,1)];
    [payload getBytes:printMode       range:NSMakeRange( 4,1)];
    [payload getBytes:serialNum       range:NSMakeRange( 5,5)];
    [payload getBytes:fwVer           range:NSMakeRange(10,3)];
    [payload getBytes:cnxVer          range:NSMakeRange(13,2)];
    [payload getBytes:tmdVer          range:NSMakeRange(15,2)];
    [payload getBytes:hwProductNum    range:NSMakeRange(17,3)];
    
    NSUInteger fwVersion = fwVer[0] << 16 | fwVer[1] << 8 | fwVer[2];
    NSUInteger cnxVersion = cnxVer[0] << 8 | cnxVer[1];
    NSUInteger tmdVersion = tmdVer[0] << 8 | tmdVer[1];
    NSUInteger hwVersion = hwProductNum[0] << 16 | hwProductNum[1] << 8 | hwProductNum[2];
    NSString *serialNumber = [NSString stringWithFormat:@"%d.%d.%d.%d.%d", serialNum[0], serialNum[1], serialNum[2], serialNum[3], serialNum[4]];
    
    MPLogDebug(@"\n\nAccessoryInfo:\n\tbatteryStatus: 0x%x => %d percent  \n\tautoPowerOff: %@  \n\tsound: %d \n\tflash: %d\n\tprintMode: %@  \n\tserialNumber: %@  \n\tfwVersion: 0x%06lx  \n\tcnxwVersion: 0x%06lx  \n\ttmdwVersion: 0x%06lx \n\thwVersion: 0x%06lx",
               batteryStatus[0], 0,
               [MPBTSprocket autoPowerOffIntervalString:autoPowerOff[0]],
               sound[0],
               flash[0],
               [MPBTSprocket printModeString:[MPBTMaui sprocketPrintModeForMauiPrintMode:printMode[0]]],
               serialNumber,
               (unsigned long)fwVersion,
               (unsigned long)cnxVersion,
               (unsigned long)tmdVersion,
               (unsigned long)hwVersion);
    
    self.batteryStatus = batteryStatus[0];
    self.firmwareVersion = fwVersion;
    self.hardwareVersion = hwVersion;
    _cnxVersion = cnxVersion;
    _tmdVersion = tmdVersion;
    _serialNumber = serialNumber;
    self.localPrintMode = printMode[0];
    self.powerOffInterval = autoPowerOff[0];
}

- (void)parseMauiResponse:(NSData *)data
{
    char startCode[2]    = {0,0};
    char customerCode[2] = {0,0};
    char hostId[1]       = {0};
    char productCode[1]  = {0};
    char cmdId[1]        = {0};
    char subCmdId[1]     = {0};
    char payload[26];    memset(payload, 0, sizeof(*payload));
           
    [data getBytes:startCode range:NSMakeRange(0, 2)];
    [data getBytes:customerCode range:NSMakeRange(2,2)];
    [data getBytes:hostId range:NSMakeRange(4,1)];
    [data getBytes:productCode range:NSMakeRange(5,1)];
    [data getBytes:cmdId range:NSMakeRange(6,1)];
    [data getBytes:subCmdId range:NSMakeRange(7,1)];
    [data getBytes:payload range:NSMakeRange(8,26)];
    
    NSData *payloadData = [[NSData alloc] initWithBytes:payload length:26];

    if (RESP_START_OF_SEND_ACK_CMD     == cmdId[0]  &&
        RESP_START_OF_SEND_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nStartOfSendAck: %@", data);
        MPLogDebug(@"\tPayload Classification: %@", [MPBTSprocket dataClassificationString:payload[0]]);
        MPLogDebug(@"\tError: %@\n\n", [MPBTSprocket errorTitle:payload[1]]);
        
        if (MauiErrorNoError == payload[1]  ||
            (MauiErrorBusy == payload[1]  &&  MauiDataClassFirmware == payload[0])) {
            if (MauiDataClassImage == payload[0]) {
                
                NSAssert( nil != self.imageData, @"No image data");
                MPBTSessionController *session = [MPBTSessionController sharedController];
                [session writeData:self.imageData];
                
            } else if (MauiDataClassFirmware == payload[0]) {
                if (nil == self.upgradeData) {
                    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
                        [self.delegate didChangeDeviceUpgradeStatus:self status:SprocketUpgradeStatusDownloadFail];
                    }
                } else {
                    MPBTSessionController *session = [MPBTSessionController sharedController];
                    [session writeData:self.upgradeData];
                }
            } else if (MauiDataClassUpgrade == payload[0]) {
                NSString *dataFile = [[NSBundle mainBundle] pathForResource:@"z21_rx_ic_11_30_03" ofType:@"rbn"];
//                NSString *dataFile = [[NSBundle mainBundle] pathForResource:@"z21_rx_ic_01_38_02" ofType:@"rbn"];
                NSURL *location = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"file://",dataFile]];
                
                NSError *error;
                self.upgradeData = [NSData dataWithContentsOfURL:location options:NSDataReadingUncached error:&error];
                [self.session writeData:[self upgradeReadyRequest]];
            }
        } else {
            MPLogDebug(@"Error returned in StartOfSendAck: %@", [MPBTSprocket errorTitle:payload[1]]);
        }
        
        // let any callers know the process is finished
        if (MauiDataClassImage == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
                [self.delegate didSendPrintData:self percentageComplete:0 error:payload[1]];
            }
        } else if (MauiDataClassFirmware == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendDeviceUpgradeData:percentageComplete:error:)]) {
                [self.delegate didSendDeviceUpgradeData:self percentageComplete:0 error:payload[1]];
            }
        }
    } else if (RESP_TMD_VERSION_CMD == cmdId[0]  &&
               RESP_TMD_VERSION_SUB_CMD == subCmdId[0]) {
        
        MPLogDebug(@"\n\ntmdVersionResponse: %@", data);
        [self.session writeData:[self upgradeRequest]];
        
    } else if (RESP_END_OF_RECEIVE_ACK_CMD == cmdId[0]  &&
               RESP_END_OF_RECEIVE_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nEndOfReceiveAck: %@", data);
        MPLogDebug(@"\tPayload Classification: %@\n\n", [MPBTSprocket dataClassificationString:payload[0]]);
        
        // let any callers know the process is finished
        if (MauiDataClassImage == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishSendingPrint:)]) {
                [self.delegate didFinishSendingPrint:self];
            }
        } else if (MauiDataClassFirmware == payload[0]) {
            if (MauiErrorNoError == payload[1]) {
                if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishSendingDeviceUpgrade:)]) {
                    [self.delegate didFinishSendingDeviceUpgrade:self];
                }

                if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
                    // We don't get upgrade status from the device... So, start and finish it right here
                    [self.delegate didChangeDeviceUpgradeStatus:self status:SprocketUpgradeStatusStart];
                    [self.delegate didChangeDeviceUpgradeStatus:self status:SprocketUpgradeStatusFinish];
                }
            } else {
                if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
                    [self.delegate didChangeDeviceUpgradeStatus:self status:SprocketUpgradeStatusFail];
                }
            }
        }
        
    } else if (RESP_GET_INFO_CMD == cmdId[0]  &&
               RESP_GET_INFO_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nGetCameraParameterResponse0: %@\n\n", data);
        [self parseAccessoryInfo:payloadData];
        NSUInteger error = payload[0];
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didRefreshSprocketInfo:error:)]) {
            [self.delegate didRefreshSprocketInfo:self error:[MPBTMaui sprocketErrorForMauiError:payload[0]]];
        }
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didCompareWithLatestFirmwareVersion:needsUpgrade:)]) {
            if (MauiErrorNoError == error) {
                [MPBTMaui latestFirmwareVersion:self.protocolString forExistingVersion:self.firmwareVersion completion:^(NSUInteger fwVersion) {
                    BOOL needsUpgrade = NO;
                    if (fwVersion > self.firmwareVersion) {
                        needsUpgrade = YES;
                    }
                    // make sure the delegate is still around now that we're in the completion block...
                    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didCompareWithLatestFirmwareVersion:needsUpgrade:)]) {
                        [self.delegate didCompareWithLatestFirmwareVersion:self needsUpgrade:needsUpgrade];
                    }
                }];
            } else {
                [self.delegate didCompareWithLatestFirmwareVersion:self needsUpgrade:NO];
            }
        }
    } else if (RESP_SET_INFO_CMD == cmdId[0]  &&
               RESP_SET_INFO_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nSetCameraParameterResponse: %@\n\n", data);
        [self parseAccessoryInfo:payloadData];
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSetAccessoryInfo:error:)]) {
            [self.delegate didSetAccessoryInfo:self error:[MPBTMaui sprocketErrorForMauiError:payload[0]]];
        }
    } else if (RESP_PRINT_START_CMD == cmdId[0]  &&
               RESP_PRINT_START_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nPrintStart: %@\n\n", data);

        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didStartPrinting:)]) {
            [self.delegate didStartPrinting:self];
        }
    } else if (RESP_ERROR_MESSAGE_ACK_CMD == cmdId[0]  &&
               RESP_ERROR_MESSAGE_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nErrorMessageAck %@", data);
        MPLogDebug(@"\tError: %@\n\n", [MPBTSprocket errorTitle:payload[0]]);
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didReceiveError:error:)]) {
            [self.delegate didReceiveError:self error:payload[0]];
        }
    } else if (RESP_PRINT_PERCENTAGE_CMD == cmdId[0]  &&
               RESP_PRINT_PERCENTAGE_SUB_CMD == subCmdId[0] ) {
        MPLogDebug(@"\n\nPrint Percentage Code: %d", (short)payload[0]);
        MPLogDebug(@"\tCurrent Image Printing Count: %d", (short)payload[3]);
    } else if (RESP_PRINT_FINISH_CMD == cmdId[0]  &&
               RESP_PRINT_FINISH_SUB_CMD == subCmdId[0] ) {
        MPLogDebug(@"\n\nPrint Finish Error Code: %d", (short)payload[0]);
        MPLogDebug(@"\tPrint Finish Current Image Printing Count: %d", (short)payload[1]);
    } else {
        MPLogDebug(@"\n\nUnrecognized response: %@\n\n", data);
    }
}

#pragma mark - Accessory Data Listeners

- (void)_sessionDataReceived:(NSNotification *)notification
{
    MPBTSessionController *sessionController = (MPBTSessionController *)[notification object];
    NSArray *packets = [sessionController getPackets];
    
    for (NSData *packet in packets) {
        [self parseMauiResponse:packet];
    }
}

- (void)_sessionDataSent:(NSNotification *)notification
{
    long long totalBytesWritten = [[notification.userInfo objectForKey:MPBTSessionDataTotalBytesWritten] longLongValue];
    long long totalBytes = self.imageData ? self.imageData.length : self.upgradeData.length;
    NSInteger percentageComplete = ((float)totalBytesWritten/(float)totalBytes) * 100;
    
    if (self.imageData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
            [self.delegate didSendPrintData:self percentageComplete:percentageComplete error:SprocketErrorNoError];
        }
    } else if (self.upgradeData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendDeviceUpgradeData:percentageComplete:error:)]) {
            [self.delegate didSendDeviceUpgradeData:self percentageComplete:percentageComplete error:SprocketErrorNoError];
        }
    }
    
    if (totalBytes - totalBytesWritten <= 0) {
        self.upgradeData = nil;
        self.imageData = nil;
    }
}

#pragma mark - Accessory Event Listeners

- (void)_sessionStreamError:(NSNotification *)notification {
    if (self.imageData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
            [self.delegate didSendPrintData:self percentageComplete:0 error:SprocketErrorDataError];
        }
    } else if (self.upgradeData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
            [self.delegate didChangeDeviceUpgradeStatus:self status:SprocketUpgradeStatusFail];
        }
    }
    
    self.imageData = nil;
    self.upgradeData = nil;
}

- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didReceiveError:error:)]) {
        [self.delegate didReceiveError:self error:SprocketErrorNoSession];
    }
}

#pragma mark - Constant Helpers

+ (SprocketDataClassification)sprocketDataClassificationForMauiDataClassification:(MauiDataClassification)class
{
    SprocketDataClassification sprocketClass = SprocketDataClassImage;
    
    switch(class) {
        case MauiDataClassTmd:
            sprocketClass = SprocketDataClassTMD;
            break;
        case MauiDataClassImage:
            sprocketClass = SprocketDataClassImage;
            break;
        case MauiDataClassFirmware:
            sprocketClass = SprocketDataClassFirmware;
            break;
        default:
            MPLogError(@"Unrecognized Maui Data Class: %d", class);
            break;
    };
    
    return sprocketClass;
}

+ (SprocketUpgradeStatus)sprocketUpgradeStatusForMauiUpgradeStatus:(MauiUpgradeStatus)status
{
    SprocketUpgradeStatus sprocketStatus = SprocketUpgradeStatusFail;
    
    switch(status) {
        case MauiUpgradeStatusStart:
            sprocketStatus = SprocketUpgradeStatusStart;
            break;
        case MauiUpgradeStatusFinish:
            sprocketStatus = SprocketUpgradeStatusFinish;
            break;
        case MauiUpgradeStatusFail:
            sprocketStatus = SprocketUpgradeStatusFail;
            break;
        case MauiUpgradeStatusDownloadFail:
            sprocketStatus = SprocketUpgradeStatusDownloadFail;
            break;
        default:
            MPLogError(@"Unrecognized Maui Upgrade Status: %d", status);
            break;
    };
    
    return sprocketStatus;
}

+ (SprocketAutoPowerOffInterval)sprocketPowerOffIntervalForMauiPowerOffInterval:(MauiAutoPowerOffInterval)interval
{
    SprocketAutoPowerOffInterval sprocketInterval = SprocketAutoOffAlwaysOn;
    
    switch (interval) {
        case MauiAutoOffThreeMin:
            sprocketInterval = SprocketAutoOffThreeMin;
            break;
        case MauiAutoOffFiveMin:
            sprocketInterval = SprocketAutoOffFiveMin;
            break;
        case MauiAutoOffTenMin:
            sprocketInterval = SprocketAutoOffTenMin;
            break;
        case MauiAutoOffAlwaysOn:
            sprocketInterval = SprocketAutoOffAlwaysOn;
            break;
            
        default:
            MPLogError(@"Unrecognized Maui Power Off Interval: %d", interval);
            break;
    };
    
    return sprocketInterval;
}

+ (MauiAutoPowerOffInterval)mauiPowerOffIntervalForSprocketPowerOffInterval:(SprocketAutoPowerOffInterval)interval
{
    MauiAutoPowerOffInterval mauiInterval = MauiAutoOffAlwaysOn;
    
    switch (interval) {
        case SprocketAutoOffThreeMin:
            mauiInterval = MauiAutoOffThreeMin;
            break;
        case SprocketAutoOffFiveMin:
            mauiInterval = MauiAutoOffFiveMin;
            break;
        case SprocketAutoOffTenMin:
            mauiInterval = MauiAutoOffTenMin;
            break;
        case SprocketAutoOffAlwaysOn:
            mauiInterval = MauiAutoOffAlwaysOn;
            break;
            
        default:
            MPLogError(@"Unrecognized Sprocket Power Off Interval: %d", interval);
            break;
    };
    
    return mauiInterval;
}

+ (SprocketPrintMode)sprocketPrintModeForMauiPrintMode:(MauiPrintMode)printMode
{
    SprocketPrintMode sprocketPrintMode = SprocketPrintModeImageFull;
    
    switch(printMode) {
        case MauiPrintModeImageFull:
            sprocketPrintMode = SprocketPrintModeImageFull;
            break;
        case MauiPrintModePaperFull:
            sprocketPrintMode = SprocketPrintModePaperFull;
            break;
        default:
            MPLogError(@"Unrecognized Maui Print Mode: %d", printMode);
            break;
    };
    
    return sprocketPrintMode;
}

+ (MauiPrintMode)mauiPrintModeForSprocketPrintMode:(SprocketPrintMode)printMode
{
    MauiPrintMode mauiPrintMode = MauiPrintModeImageFull;
    
    switch(printMode) {
        case SprocketPrintModeImageFull:
            mauiPrintMode = MauiPrintModeImageFull;
            break;
        case SprocketPrintModePaperFull:
            mauiPrintMode = MauiPrintModePaperFull;
            break;
        default:
            MPLogError(@"Unrecognized Sprocket Print Mode: %d", printMode);
            break;
    };
    
    return mauiPrintMode;
}

+ (SprocketError)sprocketErrorForMauiError:(MauiError)error
{
    SprocketError sprocketError = SprocketErrorNoError;
    
    switch (error) {
        case MauiErrorNoError:
            sprocketError = SprocketErrorNoError;
            break;
        case MauiErrorBusy:
            sprocketError = SprocketErrorBusy;
            break;
        case MauiErrorPaperJam:
            sprocketError = SprocketErrorPaperJam;
            break;
        case MauiErrorPaperEmpty:
            sprocketError = SprocketErrorPaperEmpty;
            break;
        case MauiErrorPaperMismatch:
            sprocketError = SprocketErrorPaperMismatch;
            break;
        case MauiErrorDataError:
            sprocketError = SprocketErrorDataError;
            break;
        case MauiErrorCoverOpen:
            sprocketError = SprocketErrorCoverOpen;
            break;
        case MauiErrorSystemError:
            sprocketError = SprocketErrorSystemError;
            break;
        case MauiErrorBatteryLow:
            sprocketError = SprocketErrorBatteryLow;
            break;
        case MauiErrorBatteryFault:
            sprocketError = SprocketErrorBatteryFault;
            break;
        case MauiErrorHighTemperature:
            sprocketError = SprocketErrorHighTemperature;
            break;
        case MauiErrorLowTemperature:
            sprocketError = SprocketErrorLowTemperature;
            break;
        case MauiErrorCoolingMode:
            sprocketError = SprocketErrorCoolingMode;
            break;
        case MauiErrorWrongCustomer:
            sprocketError = SprocketErrorWrongCustomer;
            break;
        case MauiErrorNoSession:
            sprocketError = SprocketErrorNoSession;
            break;
            
        default:
            MPLogError(@"Unrecognized Maui Error: %d", error);
            break;
    };
    
    return sprocketError;
}

@end
