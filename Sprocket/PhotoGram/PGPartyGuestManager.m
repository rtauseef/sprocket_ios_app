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

#import "PGPartyGuestManager.h"
#import "PGPartyFileInfo.h"
#import "PGPartyAWSTransfer.h"

@interface PGPartyGuestManager() <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *characteristic;
@property (strong, nonatomic) PGPartyFileInfo *upload;
@property (strong, nonatomic, readonly) UIImage *image;
@property (strong, nonatomic) void (^sendPhotoCompletion)(NSError *error);
@property (nonatomic, copy, nullable) void(^progressBlock)(double progress);

typedef NS_ENUM(NSInteger, PGPartyGuestManagerErrorCode) {
    PGPartyGuestManagerErrorSendInProgress = 2000
};

@end

@implementation PGPartyGuestManager
{
    dispatch_queue_t _peripheralQueue;
}

static float kImageCompression = 0.75;

static char *kPeripheralQueue = "com.hp.sprocket.queue.party.peripheral";

NSString * const kPGPartyGuestManagerErrorDomain = @"com.hp.sprocket.error.domain.party.guest";

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PGPartyGuestManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGPartyGuestManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _peripheralQueue = dispatch_queue_create(kPeripheralQueue, NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingsChangedNotification:) name:kPGPartyManagerPartyModeEnabledNotification object:nil];
    }
    return self;
}

#pragma mark - Advertising

- (void)setAdvertising:(BOOL)advertising
{
    @synchronized (self) {
        NSLog(@"ADVERTISING: %@", advertising ? @"ON" : @"OFF");
        _advertising = advertising;
        if (advertising) {
            if (nil == self.peripheralManager) {
                [self initializePeripheral];
            }
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerDidStartAdvertising)]) {
                [self.delegate partyGuestManagerDidStartAdvertising];
            }
        } else {
            if (self.peripheralManager.isAdvertising) {
                [self.peripheralManager stopAdvertising];
            }
            self.peripheralManager = nil;
            self.characteristic = nil;
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerDidStopAdvertising)]) {
                [self.delegate partyGuestManagerDidStopAdvertising];
            }
        }
    }
}

- (CBMutableService *)createService
{
    CBUUID *uuid = [CBUUID UUIDWithString:kPGPartyManagerCharacteristicUUID];
    CBCharacteristicProperties properties = (CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify | CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse);
    CBAttributePermissions permissions = (CBAttributePermissionsReadable | CBAttributePermissionsWriteable);
    self.characteristic = [[CBMutableCharacteristic alloc] initWithType:uuid properties:properties value:nil permissions:permissions];
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:kPGPartyManagerServiceUUID] primary:YES];
    service.characteristics = @[ self.characteristic ];
    return service;
}

- (void)initializePeripheral
{
    NSDictionary *options = @{ CBPeripheralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES] };
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_peripheralQueue options:options];
}

- (void)startAdvertising
{
    NSLog(@"ADVERTISING: START ADVERTISING");
    
    [self.peripheralManager removeAllServices];
    [self.peripheralManager addService:[self createService]];
    
    NSDictionary *data = @{
                           CBAdvertisementDataLocalNameKey: [[UIDevice currentDevice] name],
                           CBAdvertisementDataServiceUUIDsKey: @[ [CBUUID UUIDWithString:kPGPartyManagerServiceUUID] ]
                           };
    
    [self.peripheralManager startAdvertising:data];
}

- (void)advertisingError:(NSInteger)code description:(NSString *)description
{
    NSError *error = [NSError errorWithDomain:kPGPartyGuestManagerErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: description}];
    NSLog(@"ADVERTISING: ERROR: %@", error);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerAdvertisingError:)]) {
        [self.delegate partyGuestManagerAdvertisingError:error];
    }
    self.advertising = NO;
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"PERIPHERAL MANAGER: STATE CHANGE: (%ld) %@", (long)peripheral.state, [self bluetoothState:peripheral.state]);
    
    if (CBManagerStatePoweredOn == peripheral.state) {
        if (!self.peripheralManager.isAdvertising) {
            [self startAdvertising];
        } else {
            NSLog(@"PERIPHERAL MANAGER: ALREADY ADVERTISING");
        }
    } else if (CBManagerStateUnsupported == peripheral.state) {
        [self advertisingError:PGPartyManagerErrorBluetoothUnsupported description:NSLocalizedString(@"The platform doesn't support the Bluetooth Low Energy Central/Client role.", nil)];
    } else if (CBManagerStateUnauthorized == peripheral.state) {
        [self advertisingError:PGPartyManagerErrorBluetoothUnauthorized description:NSLocalizedString(@"The application is not authorized to use the Bluetooth Low Energy role.", nil)];
    } else if (CBManagerStatePoweredOff == peripheral.state) {
        [self.peripheralManager stopAdvertising];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    NSLog(@"PERIPHERAL MANAGER: STARTED ADVERTISING: %@", error);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"PERIPHERAL MANAGER: CENTRAL SUBSCRIBED: %@", central);
    [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:central];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerDidConnectCentral)]) {
        [self.delegate partyGuestManagerDidConnectCentral];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"PERIPHERAL MANAGER: RECEIVED READ REQUEST: %@", request);
    [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"PERIPHERAL MANAGER: READY TO UPDATE");
    [self updateUploadStats];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"PERIPHERAL MANAGER: CENTRAL UNSUBSCRIBED: %@", central);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerDidDisconnectCentral)]) {
        [self.delegate partyGuestManagerDidDisconnectCentral];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    NSLog(@"PERIPHERAL MANAGER: RECEIVED WRITE REQUESTS: %ld", (unsigned long)requests.count);
    BOOL complete = NO;
    for (CBATTRequest *request in requests) {
        self.characteristic.value = request.value;
        NSLog(@"PERIPHERAL MANAGER: WROTE REQUESTED VALUE: %@", request.value);
        NSUInteger size = [PGPartyFileInfo sizeFromPacket:request.value];
        NSUInteger received = [PGPartyFileInfo receivedFromPacket:request.value];
        float progress = (float)received / (float)size;
        if (nil != self.progressBlock) {
            self.progressBlock(0.5 + progress / 2.0);
        }
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerDownloadProgress:)]) {
            [self.delegate partyGuestManagerDownloadProgress:progress];
        }
        if (received == size) {
            complete = YES;
        }
    }
    [self.peripheralManager respondToRequest:[requests firstObject] withResult:CBATTErrorSuccess];
    if (complete) {
        NSLog(@"PERIPHERAL MANAGER: DOWNLOAD COMPLETE!");
        [self notifySendComplete:nil];
    }
}

#pragma mark - Send Photo


- (void)sendImage:(UIImage *)image
{
    [self sendImage:image progress:nil completion:nil];
}

- (void)sendImage:(UIImage *)image progress:(void(^_Nullable)(double progress))progress completion:(void (^_Nullable)(NSError *error))completion
{
    @synchronized (self) {
        if (nil != _image) {
            if (nil != completion) {
                NSError *error = [NSError errorWithDomain:kPGPartyGuestManagerErrorDomain code:PGPartyGuestManagerErrorSendInProgress userInfo:@{NSLocalizedDescriptionKey: @"Send already in progress. Please wait for current send operation to complete before initiating a new one."}];
                completion(error);
            }
        }
        self.sendPhotoCompletion = completion;
        self.progressBlock = progress;
        _image = image;
    }

    NSUInteger identifier = arc4random_uniform(pow(256, 4));
    NSData *data = UIImageJPEGRepresentation(image, kImageCompression);
    self.upload = [[PGPartyFileInfo alloc] initWithIdentifier:identifier data:data];
    [self updateUploadStats];
    [[PGPartyAWSTransfer sharedInstance] upload:self.upload progress:^(NSUInteger bytesSent) {
        if (bytesSent < self.upload.size) {
            NSLog(@"UPLOAD: SEND PROGRESS");
            self.upload.sent = bytesSent;
            [self updateUploadStats];
        }
    } completion:^(NSError *error) {
        if (nil == error) {
            NSLog(@"UPLOAD: SEND IMAGE COMPLETE");
            self.upload.sent = self.upload.size;
            [self updateUploadStats];
        } else {
            NSLog(@"UPLOAD: SEND IMAGE ERROR: %@", error);
            [self notifySendComplete:error];
        }
    }];
}

- (void)notifySendComplete:(NSError *)error
{
    @synchronized (self) {
        if (nil != self.sendPhotoCompletion) {
            self.sendPhotoCompletion(error);
        }
        if (nil == error) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerHostReceivedImage:)]) {
                [self.delegate partyGuestManagerHostReceivedImage:self.image];
            }
        }
        self.sendPhotoCompletion = nil;
        self.progressBlock = nil;
        _image = nil;
        self.upload = nil;
    }
}

- (void)updateUploadStats
{
    @synchronized (self) {
        NSData *packet = self.upload.packet;
        self.characteristic.value = packet;
        BOOL result = [self.peripheralManager updateValue:packet forCharacteristic:self.characteristic onSubscribedCentrals:nil];
        if (result) {
            NSLog(@"UPLOAD: UPDATE STATS: %lu", (unsigned long)[PGPartyFileInfo sentFromPacket:packet]);
            float progress = (float)self.upload.sent / (float)self.upload.size;
            if (nil != self.progressBlock) {
                self.progressBlock(progress / 2.0);
            }
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(partyGuestManagerUploadProgress:)]) {
                [self.delegate partyGuestManagerUploadProgress:progress];
            }
        }
    }
}

#pragma mark - Connections

- (BOOL)connected
{
    return nil != self.peripheralManager && nil != self.characteristic && self.characteristic.subscribedCentrals.count > 0;
}

#pragma mark - Notifications

- (void)handleSettingsChangedNotification:(NSNotification *)notification
{
    if (![PGPartyManager isPartyModeEnabled]) {
        self.advertising = NO;
    }
}

@end
