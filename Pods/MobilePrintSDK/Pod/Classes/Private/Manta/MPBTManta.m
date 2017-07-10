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

#import "MPBTManta.h"
#import "MPBTSessionController.h"
#import "MPPrintItemImage.h"
#import "NSBundle+MPLocalizable.h"
#import "MP.h"

const char MANTA_PACKET_LENGTH = 34;

static const NSString *kHpProtocol = @"com.hp.protocol";

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

static const char CMD_GET_INFO_CMD          = 0x01;
static const char CMD_GET_INFO_SUB_CMD      = 0x00;

static const char CMD_SET_INFO_CMD          = 0x01;
static const char CMD_SET_INFO_SUB_CMD      = 0x01;

static const char CMD_UPGRADE_READY_CMD     = 0x03;
static const char CMD_UPGRADE_READY_SUB_CMD = 0x00;

// Responses
static const char RESP_PRINT_START_CMD            = 0x00;
static const char RESP_PRINT_START_SUB_CMD        = 0x02;

static const char RESP_ACCESSORY_INFO_ACK_CMD     = 0x01;
static const char RESP_ACCESSORY_INFO_ACK_SUB_CMD = 0x02;

static const char RESP_START_OF_SEND_ACK_CMD      = 0x02;
static const char RESP_START_OF_SEND_ACK_SUB_CMD  = 0x00;

static const char RESP_END_OF_RECEIVE_ACK_CMD     = 0x02;
static const char RESP_END_OF_RECEIVE_ACK_SUB_CMD = 0x01;

static const char RESP_UPGRADE_ACK_CMD            = 0x03;
static const char RESP_UPGRADE_ACK_SUB_CMD        = 0x02;

static const char RESP_ERROR_MESSAGE_ACK_CMD      = 0x04;
static const char RESP_ERROR_MESSAGE_ACK_SUB_CMD  = 0x00;


@import UIKit;

@interface MPBTManta () <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) MPBTSessionController *session;
@property (strong, nonatomic) NSData* imageData;
@property (strong, nonatomic) NSData* upgradeData;
@property (strong, nonatomic) NSArray *supportedProtocols;
@property (assign, nonatomic) MantaAutoPowerOffInterval localPowerOffInterval;
@property (assign, nonatomic) MantaPrintMode localPrintMode;

@end

@implementation MPBTManta

#pragma mark - Public methods

+ (MPBTManta *)sharedInstance
{
    static MPBTManta *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MPBTManta alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.supportedProtocols = @[kHpProtocol/*, kPolaroidProtocol, @"com.lge.pocketphoto"*/];
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
    [MPBTSprocket latestFirmwarePath:self.protocolString forExistingVersion:[self adjustedFirmwareVersion] completion:^(NSString *fwPath) {
        
        NSURLSession *httpSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue: [NSOperationQueue mainQueue]];
        
        [[httpSession downloadTaskWithURL:[NSURL URLWithString:fwPath]] resume];
    }];
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
    MantaAutoPowerOffInterval newInterval = [MPBTManta mantaPowerOffIntervalForSprocketPowerOffInterval:powerOffInterval];
    
    if (self.localPowerOffInterval != newInterval) {
        self.localPowerOffInterval = newInterval;
        [self.session writeData:[self setInfoRequest]];
    }
}

- (SprocketAutoPowerOffInterval)powerOffInterval
{
    return [MPBTManta sprocketPowerOffIntervalForMantaPowerOffInterval:self.localPowerOffInterval];
}

- (void)setPrintMode:(SprocketPrintMode)printMode
{
    MantaPrintMode newMode = [MPBTManta mantaPrintModeForSprocketPrintMode:printMode];

    if (self.localPrintMode != newMode) {
        self.localPrintMode = newMode;
        [self.session writeData:[self setInfoRequest]];
    }
}

- (SprocketPrintMode)printMode
{
    return [MPBTManta sprocketPrintModeForMantaPrintMode:_localPrintMode];
}

- (void)setAutoExposure:(MantaAutoExposure)autoExposure
{
    if (_autoExposure != autoExposure) {
        _autoExposure = autoExposure;
        [self.session writeData:[self setInfoRequest]];
    }
}

- (NSString *)displayName
{
    return [MPBTSprocket displayNameForAccessory:self.accessory];
}

- (NSUInteger) adjustedFirmwareVersion
{
    NSUInteger fwVer = [MPBTSprocket forceFirmwareUpdates] ? self.firmwareVersion-1 : self.firmwareVersion;
    return fwVer;
}

- (NSDictionary *)analytics
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setValue:[MPBTSprocket macAddress:self.macAddress] forKey:kMPPrinterId];
    [dictionary setValue:[MPBTSprocket displayNameForAccessory:self.accessory] forKey:kMPPrinterDisplayName];
    [dictionary setValue:[NSString stringWithFormat:@"HP sprocket"] forKey:kMPPrinterMakeAndModel];
    
    NSString *fwVersion  = [MPBTSprocket version:self.firmwareVersion] ? [MPBTSprocket version:self.firmwareVersion] : @"";
    NSString *tmdVersion = [MPBTSprocket version:self.hardwareVersion] ? [MPBTSprocket version:self.hardwareVersion] : @"";
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

- (void)setupPacket:(char[MANTA_PACKET_LENGTH])packet command:(char)command subcommand:(char)subcommand
{
    memset(packet, 0, MANTA_PACKET_LENGTH);
    
    packet[0] = START_CODE_BYTE_1;
    packet[1] = START_CODE_BYTE_2;
    
    if ([self.protocolString isEqualToString:[kPolaroidProtocol copy]]) {
        packet[2] = POLAROID_CUSTOMER_CODE_BYTE_1;
        packet[3] = POLAROID_CUSTOMER_CODE_BYTE_2;
    } else if ([self.protocolString isEqualToString:[kHpProtocol copy]]){
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
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_GET_INFO_CMD subcommand:CMD_GET_INFO_SUB_CMD];
    
    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];
    
    MPLogDebug(@"accessoryInfoRequest: %@", data);
    
    return data;
}

- (NSData *)printReadyRequest:(NSInteger)numCopies
{
    NSMutableData *data;
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_PRINT_READY_CMD subcommand:CMD_PRINT_READY_SUB_CMD];
    
    // imageSize
    NSUInteger imageSize = self.imageData.length;
    byteArray[8] = (0xFF0000 & imageSize) >> 16;
    byteArray[9] = (0x00FF00 & imageSize) >>  8;
    byteArray[10] = 0x0000FF & imageSize;
    
    // printCount
    byteArray[11] = numCopies <= 4 ? numCopies : 4;
    
    // printMode
    byteArray[15] = 0x00;
    
    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];
    
    MPLogDebug(@"printReadyRequest: %@", data);
    
    return data;
}

- (NSData *)upgradeReadyRequest
{
    NSMutableData *data;
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_UPGRADE_READY_CMD subcommand:CMD_UPGRADE_READY_SUB_CMD];
    
    // imageSize
    NSUInteger imageSize = self.upgradeData.length;
    byteArray[8] = (0xFF0000 & imageSize) >> 16;
    byteArray[9] = (0x00FF00 & imageSize) >>  8;
    byteArray[10] = 0x0000FF & imageSize;
    
    // dataClassification
    byteArray[11] = MantaDataClassFirmware;
    
    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];
    
    MPLogDebug(@"upgradeReadyRequest: %@", data);
    
    return data;
}

- (NSData *)setInfoRequest
{
    NSMutableData *data;
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_SET_INFO_CMD subcommand:CMD_SET_INFO_SUB_CMD];
    
    byteArray[8]  = self.autoExposure;
    byteArray[9]  = self.localPowerOffInterval;
    byteArray[10] = self.localPrintMode;
    
    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];
    
    MPLogDebug(@"setInfoRequest: %@", data);
    
    return data;
}

#pragma mark - Parsers

- (void)parseAccessoryInfo:(NSData *)payload
{
    char errorCode[]       = {0};
    char totalPrintCount[] = {0,0};
    char printMode[]       = {0};
    char batteryStatus[]   = {0};
    char autoExposure[]    = {0};
    char autoPowerOff[]    = {0};
    char macAddress[]      = {0,0,0,0,0,0};
    char fwVersion[]       = {0,0,0};
    char hwVersion[]       = {0,0,0};
    // Note: maxPayloadSize is only available on Android... not forgotten here
    
    [payload getBytes:errorCode       range:NSMakeRange( 0,1)];
    [payload getBytes:totalPrintCount range:NSMakeRange( 1,2)];
    [payload getBytes:printMode       range:NSMakeRange( 3,1)];
    [payload getBytes:batteryStatus   range:NSMakeRange( 4,1)];
    [payload getBytes:autoExposure    range:NSMakeRange( 5,1)];
    [payload getBytes:autoPowerOff    range:NSMakeRange( 6,1)];
    [payload getBytes:macAddress      range:NSMakeRange( 7,6)];
    [payload getBytes:fwVersion       range:NSMakeRange(13,3)];
    [payload getBytes:hwVersion       range:NSMakeRange(16,3)];
    
    NSData *macAddressData = [[NSData alloc] initWithBytes:macAddress length:6];
    NSUInteger printCount = totalPrintCount[0] << 8 | totalPrintCount[1];
    NSUInteger firmwareVersion = fwVersion[0] << 16 | fwVersion[1] << 8 | fwVersion[2];
    NSUInteger hardwareVersion = hwVersion[0] << 16 | hwVersion[1] << 8 | hwVersion[2];
    
    MPLogDebug(@"\n\nAccessoryInfo:\n\terrorCode: %@  \n\ttotalPrintCount: 0x%04lx  \n\tprintMode: %@  \n\tbatteryStatus: 0x%x => %d percent  \n\tautoExposure: %@  \n\tautoPowerOff: %@  \n\tmacAddress: %@  \n\tfwVersion: 0x%06lx  \n\thwVersion: 0x%06lx",
               [MPBTSprocket errorTitle:errorCode[0]],
               (unsigned long)printCount,
               [MPBTSprocket printModeString:[MPBTManta sprocketPrintModeForMantaPrintMode:printMode[0]]],
               batteryStatus[0], batteryStatus[0],
               [MPBTSprocket autoExposureString:[MPBTManta sprocketAutoExposureForMantaAutoExposure:autoExposure[0]]],
               [MPBTSprocket autoPowerOffIntervalString:autoPowerOff[0]],
               [MPBTSprocket macAddress:macAddressData],
               (unsigned long)firmwareVersion,
               (unsigned long)hardwareVersion);
    
    self.totalPrintCount = printCount;
    self.batteryStatus = batteryStatus[0];
    self.macAddress = macAddressData;
    self.firmwareVersion = firmwareVersion;
    self.hardwareVersion = hardwareVersion;
    self.localPrintMode = printMode[0];
    _autoExposure = autoExposure[0]; // bypass setter
    self.localPowerOffInterval = autoPowerOff[0];
}

- (void)parseMantaResponse:(NSData *)data
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
        MPLogDebug(@"\tPayload Classification: %@", [MPBTSprocket dataClassificationString:[MPBTManta sprocketDataClassificationForMantaDataClassification:payload[0]]]);
        MPLogDebug(@"\tError: %@\n\n", [MPBTSprocket errorTitle:payload[1]]);
        
        if (MantaErrorNoError == payload[1]  ||
            (MantaErrorBusy == payload[1]  &&  MantaDataClassFirmware == payload[0])) {
            if (MantaDataClassImage == payload[0]) {
                
                NSAssert( nil != self.imageData, @"No image data");
                MPBTSessionController *session = [MPBTSessionController sharedController];
                [session writeData:self.imageData];
                
            } else if (MantaDataClassFirmware == payload[0]) {
                if (nil == self.upgradeData) {
                    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
                        [self.delegate didChangeDeviceUpgradeStatus:self status:SprocketUpgradeStatusDownloadFail];
                    }
                } else {
                    MPBTSessionController *session = [MPBTSessionController sharedController];
                    [session writeData:self.upgradeData];
                }
            }
        } else {
            MPLogDebug(@"Error returned in StartOfSendAck: %@", [MPBTSprocket errorTitle:payload[1]]);
        }
        
        // let any callers know the process is finished
        if (MantaDataClassImage == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
                [self.delegate didSendPrintData:self percentageComplete:0 error:payload[1]];
            }
        } else if (MantaDataClassFirmware == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendDeviceUpgradeData:percentageComplete:error:)]) {
                [self.delegate didSendDeviceUpgradeData:self percentageComplete:0 error:payload[1]];
            }
        }
    } else if (RESP_END_OF_RECEIVE_ACK_CMD == cmdId[0]  &&
               RESP_END_OF_RECEIVE_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nEndOfReceiveAck: %@", data);
        MPLogDebug(@"\tPayload Classification: %@\n\n", [MPBTSprocket dataClassificationString:payload[0]]);
        
        // let any callers know the process is finished
        if (MantaDataClassImage == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishSendingPrint:)]) {
                [self.delegate didFinishSendingPrint:self];
            }
        } else if (MantaDataClassFirmware == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishSendingDeviceUpgrade:)]) {
                [self.delegate didFinishSendingDeviceUpgrade:self];
            }
        }
        
    } else if (RESP_ACCESSORY_INFO_ACK_CMD == cmdId[0]  &&
               RESP_ACCESSORY_INFO_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nAccessoryInfoAck: %@\n\n", data);
        [self parseAccessoryInfo:payloadData];
        NSUInteger error = payload[0];
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didRefreshSprocketInfo:error:)]) {
            [self.delegate didRefreshSprocketInfo:self error:[MPBTManta sprocketErrorForMantaError:payload[0]]];
        }
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didCompareWithLatestFirmwareVersion:needsUpgrade:)]) {
            if (MantaErrorNoError == error) {
                [MPBTSprocket latestFirmwareVersion:self.protocolString forExistingVersion:[self adjustedFirmwareVersion] completion:^(NSUInteger fwVersion) {
                    BOOL needsUpgrade = NO;
                    if (fwVersion > [self adjustedFirmwareVersion]) {
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
    } else if (RESP_UPGRADE_ACK_CMD == cmdId[0]  &&
               RESP_UPGRADE_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nUpgradeAck %@", data);
        MPLogDebug(@"\tUpgrade status: %@\n\n", [MPBTSprocket upgradeStatusString:[MPBTManta sprocketUpgradeStatusForMantaUpgradeStatus:payload[0]]]);
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
            [self.delegate didChangeDeviceUpgradeStatus:self status:payload[0]];
        }
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
        [self parseMantaResponse:packet];
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

+ (SprocketDataClassification)sprocketDataClassificationForMantaDataClassification:(MantaDataClassification)class
{
    SprocketDataClassification sprocketClass = SprocketDataClassImage;
    
    switch(class) {
        case MantaDataClassTMD:
            sprocketClass = SprocketDataClassTMD;
            break;
        case MantaDataClassImage:
            sprocketClass = SprocketDataClassImage;
            break;
        case MantaDataClassFirmware:
            sprocketClass = SprocketDataClassFirmware;
            break;
        default:
            MPLogError(@"Unrecognized Manta Data Class: %d", class);
            break;
    };
    
    return sprocketClass;
}

+ (SprocketUpgradeStatus)sprocketUpgradeStatusForMantaUpgradeStatus:(MantaUpgradeStatus)status
{
    SprocketUpgradeStatus sprocketStatus = SprocketUpgradeStatusFail;
    
    switch(status) {
        case MantaUpgradeStatusStart:
            sprocketStatus = SprocketUpgradeStatusStart;
            break;
        case MantaUpgradeStatusFinish:
            sprocketStatus = SprocketUpgradeStatusFinish;
            break;
        case MantaUpgradeStatusFail:
            sprocketStatus = SprocketUpgradeStatusFail;
            break;
        case MantaUpgradeStatusDownloadFail:
            sprocketStatus = SprocketUpgradeStatusDownloadFail;
            break;
        default:
            MPLogError(@"Unrecognized Manta Upgrade Status: %d", status);
            break;
    };
    
    return sprocketStatus;
}

+ (SprocketAutoPowerOffInterval)sprocketPowerOffIntervalForMantaPowerOffInterval:(MantaAutoPowerOffInterval)interval
{
    SprocketAutoPowerOffInterval sprocketInterval = SprocketAutoOffAlwaysOn;
    
    switch (interval) {
        case MantaAutoOffThreeMin:
            sprocketInterval = SprocketAutoOffThreeMin;
            break;
        case MantaAutoOffFiveMin:
            sprocketInterval = SprocketAutoOffFiveMin;
            break;
        case MantaAutoOffTenMin:
            sprocketInterval = SprocketAutoOffTenMin;
            break;
        case MantaAutoOffAlwaysOn:
            sprocketInterval = SprocketAutoOffAlwaysOn;
            break;
            
        default:
            MPLogError(@"Unrecognized Manta Power Off Interval: %d", interval);
            break;
    };
    
    return sprocketInterval;
}

+ (MantaAutoPowerOffInterval)mantaPowerOffIntervalForSprocketPowerOffInterval:(SprocketAutoPowerOffInterval)interval
{
    MantaAutoPowerOffInterval mantaInterval = MantaAutoOffAlwaysOn;
    
    switch (interval) {
        case SprocketAutoOffThreeMin:
            mantaInterval = MantaAutoOffThreeMin;
            break;
        case SprocketAutoOffFiveMin:
            mantaInterval = MantaAutoOffFiveMin;
            break;
        case SprocketAutoOffTenMin:
            mantaInterval = MantaAutoOffTenMin;
            break;
        case SprocketAutoOffAlwaysOn:
            mantaInterval = MantaAutoOffAlwaysOn;
            break;
            
        default:
            MPLogError(@"Unrecognized Sprocket Power Off Interval: %d", interval);
            break;
    };
    
    return mantaInterval;
}

+ (SprocketPrintMode)sprocketPrintModeForMantaPrintMode:(MantaPrintMode)printMode
{
    SprocketPrintMode sprocketPrintMode = SprocketPrintModeImageFull;
    
    switch(printMode) {
        case MantaPrintModeImageFull:
            sprocketPrintMode = SprocketPrintModeImageFull;
            break;
        case MantaPrintModePaperFull:
            sprocketPrintMode = SprocketPrintModePaperFull;
            break;
        default:
            MPLogError(@"Unrecognized Manta Print Mode: %d", printMode);
            break;
    };
    
    return sprocketPrintMode;
}

+ (MantaPrintMode)mantaPrintModeForSprocketPrintMode:(SprocketPrintMode)printMode
{
    MantaPrintMode mantaPrintMode = MantaPrintModeImageFull;
    
    switch(printMode) {
        case SprocketPrintModeImageFull:
            mantaPrintMode = MantaPrintModeImageFull;
            break;
        case SprocketPrintModePaperFull:
            mantaPrintMode = MantaPrintModePaperFull;
            break;
        default:
            MPLogError(@"Unrecognized Sprocket Print Mode: %d", printMode);
            break;
    };
    
    return mantaPrintMode;
}

+ (SprocketAutoExposure)sprocketAutoExposureForMantaAutoExposure:(MantaAutoExposure)autoExposure
{
    SprocketAutoExposure sprocketAutoExposure = SprocketAutoExposureOn;
    
    switch(autoExposure) {
        case MantaAutoExposureOn:
            sprocketAutoExposure = SprocketAutoExposureOn;
            break;
        case MantaAutoExposureOff:
            sprocketAutoExposure = SprocketAutoExposureOff;
            break;
        default:
            MPLogError(@"Unrecognized Manta Auto Exposure: %d", autoExposure);
            break;
    };
    
    return sprocketAutoExposure;
}

+ (SprocketError)sprocketErrorForMantaError:(MantaError)error
{
    SprocketError sprocketError = SprocketErrorNoError;
    
    switch (error) {
        case MantaErrorNoError:
            sprocketError = SprocketErrorNoError;
            break;
        case MantaErrorBusy:
            sprocketError = SprocketErrorBusy;
            break;
        case MantaErrorPaperJam:
            sprocketError = SprocketErrorPaperJam;
            break;
        case MantaErrorPaperEmpty:
            sprocketError = SprocketErrorPaperEmpty;
            break;
        case MantaErrorPaperMismatch:
            sprocketError = SprocketErrorPaperMismatch;
            break;
        case MantaErrorDataError:
            sprocketError = SprocketErrorDataError;
            break;
        case MantaErrorCoverOpen:
            sprocketError = SprocketErrorCoverOpen;
            break;
        case MantaErrorSystemError:
            sprocketError = SprocketErrorSystemError;
            break;
        case MantaErrorBatteryLow:
            sprocketError = SprocketErrorBatteryLow;
            break;
        case MantaErrorBatteryFault:
            sprocketError = SprocketErrorBatteryFault;
            break;
        case MantaErrorHighTemperature:
            sprocketError = SprocketErrorHighTemperature;
            break;
        case MantaErrorLowTemperature:
            sprocketError = SprocketErrorLowTemperature;
            break;
        case MantaErrorCoolingMode:
            sprocketError = SprocketErrorCoolingMode;
            break;
        case MantaErrorWrongCustomer:
            sprocketError = SprocketErrorWrongCustomer;
            break;
        case MantaErrorNoSession:
            sprocketError = SprocketErrorNoSession;
            break;
            
        default:
            MPLogError(@"Unrecognized Manta Error: %d", error);
            break;
    };

    return sprocketError;
}

@end
