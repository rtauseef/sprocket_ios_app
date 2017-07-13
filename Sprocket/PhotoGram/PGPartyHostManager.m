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

#import "PGPartyHostManager.h"
#import "PGPartyFileInfo.h"
#import "PGPartyAWSTransfer.h"
#import "PGFeatureFlag.h"

@interface PGPartyHostManager() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray<CBPeripheral *> *connectedPeripherals;
@property (strong, nonatomic) NSMutableDictionary<CBPeripheral *, PGPartyFileInfo *> *downloads;
@property (readonly, nonatomic) dispatch_queue_t centralQueue;

@end

@implementation PGPartyHostManager

static char * const kCentralQueue = "com.hp.sprocket.queue.party.central";

static NSString * const kDefaultName = @"Party Device";

NSString * const kPGPartyHostManagerErrorDomain = @"com.hp.sprocket.error.domain.party.host";

NSString * const kPGPartyManagerPeripheralIdentifierKey = @"com.hp.sprocket.key.party.peripheral.identifier";
NSString * const kPGPartyManagerPeripheralNameKey = @"com.hp.sprocket.key.party.peripheral.name";

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PGPartyHostManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGPartyHostManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _centralQueue = dispatch_queue_create(kCentralQueue, NULL);
        self.connectedPeripherals = [NSMutableArray array];
        self.downloads = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingsChangedNotification:) name:kPGFeatureFlagPartyModeEnabledNotification object:nil];
    }
    return self;
}

#pragma mark - Scanning

- (void)setScanning:(BOOL)scanning
{
    @synchronized (self) {
        PGLogDebug(@"SCANNING: %@", scanning ? @"ON" : @"OFF");
        _scanning = scanning;
        if (scanning) {
            if (nil == self.centralManager) {
                [self initializeCentral];
            }
            if ([self.delegate respondsToSelector:@selector(partyHostManagerDidStartScanning)]) {
                [self.delegate partyHostManagerDidStartScanning];
            }
        } else {
            if (self.centralManager.isScanning) {
                [self.centralManager stopScan];
            }
            for (CBPeripheral *peripheral in [self.centralManager retrieveConnectedPeripheralsWithServices:@[ [CBUUID UUIDWithString:kPGPartyManagerServiceUUID] ]]) {
                [self.centralManager cancelPeripheralConnection:peripheral];
            }
            self.connectedPeripherals = [NSMutableArray array];
            self.centralManager = nil;
            if ([self.delegate respondsToSelector:@selector(partyHostManagerDidStopScanning)]) {
                [self.delegate partyHostManagerDidStopScanning];
            }
        }
    }
}

- (void)initializeCentral
{
    NSDictionary *options = @{ CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:YES] };
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralQueue options:options];
}

- (void)startScanning
{
    PGLogDebug(@"SCANNING: START SCANNING");
    
    [self.centralManager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:kPGPartyManagerServiceUUID] ] options:nil];
}

- (void)scanningError:(NSInteger)code description:(NSString *)description
{
    NSError *error = [NSError errorWithDomain:kPGPartyHostManagerErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: description}];
    PGLogError(@"SCANNING: ERROR: %@", error);
    if ([self.delegate respondsToSelector:@selector(partyHostManagerScanningError:)]) {
        [self.delegate partyHostManagerScanningError:error];
    }
    self.scanning = NO;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    PGLogDebug(@"CENTRAL MANAGER: STATE CHANGE: (%ld) %@", (long)central.state, [self bluetoothState:central.state]);
    
    if (CBManagerStatePoweredOn == central.state) {
        if (!self.centralManager.isScanning) {
            [self startScanning];
        } else {
            PGLogDebug(@"CENTRAL MANAGER: ALREADY SCANNING");
        }
    } else if (CBManagerStateUnsupported == central.state) {
        [self scanningError:PGPartyManagerErrorBluetoothUnsupported description:NSLocalizedString(@"The platform doesn't support the Bluetooth Low Energy Central/Client role.", nil)];
    } else if (CBManagerStateUnauthorized == central.state) {
        [self scanningError:PGPartyManagerErrorBluetoothUnauthorized description:NSLocalizedString(@"The application is not authorized to use the Bluetooth Low Energy role.", nil)];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    PGLogDebug(@"CENTRAL MANAGER: PERIPHERAL FOUND: %@: %@: %@", RSSI, peripheral, advertisementData);
    
    if (CBPeripheralStateDisconnected == peripheral.state) {
        [self addPeripheral:peripheral];
        [self.centralManager connectPeripheral:peripheral options:nil];
        PGLogDebug(@"CENTRAL MANAGER: CONNECTING: %@", peripheral);
    } else if (CBPeripheralStateConnected == peripheral.state) {
        PGLogDebug(@"CENTRAL MANAGER: ALREADY CONNECTED: %@", peripheral);
    } else { // CBPeripheralStateConnecting || CBPeripheralStateDisconnecting
        PGLogDebug(@"CENTRAL MANAGER: BUSY: %@", peripheral);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    PGLogDebug(@"CENTRAL MANAGER: CONNECTED PERIPHERAL: %@", [self infoForPeripheral:peripheral]);
    CBUUID *serviceUUID = [CBUUID UUIDWithString:kPGPartyManagerServiceUUID];
    [peripheral discoverServices:@[ serviceUUID ]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    PGLogError(@"CENTRAL MANAGER: FAILED TO CONNECT PERIPHERAL: %@\nERROR: %@", [self infoForPeripheral:peripheral], error);
    [self removePeripheral:peripheral];
    if ([self.delegate respondsToSelector:@selector(partyHostManagerPeripheralError:error:)]) {
        [self.delegate partyHostManagerPeripheralError:[self infoForPeripheral:peripheral] error:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    PGLogError(@"CENTRAL MANAGER: DISCONNECTED PERIPHERAL: %@\nERROR: %@", [self infoForPeripheral:peripheral], error);
    [self removePeripheral:peripheral];
    if ([self.delegate respondsToSelector:@selector(partyHostManagerDidDisconnectPeripheral:error:)]) {
        [self.delegate partyHostManagerDidDisconnectPeripheral:[self infoForPeripheral:peripheral] error:error];
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    PGLogDebug(@"PERIPHERAL: INVALIDATED SERVICES");
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    PGLogDebug(@"PERIPHERAL: MODIFIED SERVICES: %@", invalidatedServices);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    PGLogDebug(@"PERIPHERAL: DISCOVERED SERVICES: %@", error);
    if (error) {
        if ([self.delegate respondsToSelector:@selector(partyHostManagerPeripheralError:error:)]) {
            [self.delegate partyHostManagerPeripheralError:[self infoForPeripheral:peripheral] error:error];
        }
        [self.centralManager cancelPeripheralConnection:peripheral];
    } else {
        CBUUID *characteristic = [CBUUID UUIDWithString:kPGPartyManagerCharacteristicUUID];
        [peripheral discoverCharacteristics:@[ characteristic ] forService:[peripheral.services firstObject]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    PGLogDebug(@"PERIPHERAL: DISCOVERED CHARACTERISTICS: %@", error);
    if (error) {
        if ([self.delegate respondsToSelector:@selector(partyHostManagerPeripheralError:error:)]) {
            [self.delegate partyHostManagerPeripheralError:[self infoForPeripheral:peripheral] error:error];
        }
        [self.centralManager cancelPeripheralConnection:peripheral];
    } else {
        [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics firstObject]];
    }
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    PGLogDebug(@"PERIPHERAL: UPDATED NAME: %@", peripheral);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    PGLogDebug(@"PERIPHERAL: UPDATED NOTIFICATION STATE: %@", error);
    if (error) {
        if ([self.delegate respondsToSelector:@selector(partyHostManagerPeripheralError:error:)]) {
            [self.delegate partyHostManagerPeripheralError:[self infoForPeripheral:peripheral] error:error];
        }
        [self.centralManager cancelPeripheralConnection:peripheral];
    } else {
        if ([self.delegate respondsToSelector:@selector(partyHostManagerDidConnectPeripheral:)]) {
            [self.delegate partyHostManagerDidConnectPeripheral:[self infoForPeripheral:peripheral]];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSUInteger identifier = [PGPartyFileInfo identifierFromPacket:characteristic.value];
    NSUInteger size = [PGPartyFileInfo sizeFromPacket:characteristic.value];
    NSUInteger sent = [PGPartyFileInfo sentFromPacket:characteristic.value];
//    NSUInteger received = [PGPartyFileInfo receivedFromPacket:characteristic.value];
    
    PGPartyFileInfo *info = [self fileInfoForPeripheral:peripheral];
    if (info.identifier != identifier) {
        [self.downloads removeObjectForKey:peripheral];
        info = nil;
    }
    if (nil == info) {
        info = [[PGPartyFileInfo alloc] initWithIdentifier:identifier size:size];
        [self.downloads addEntriesFromDictionary:@{peripheral: info}];
    }
    info.sent = sent;
    
    PGLogDebug(@"PERIPHERAL: UPDATED VALUE: %lu: %lu: %@", (unsigned long)size, (unsigned long)sent, error);
    
    if ([self.delegate respondsToSelector:@selector(partyHostManagerUploadProgress:identifier:)]) {
        CGFloat progress = (CGFloat)info.sent / (CGFloat)info.size;
        [self.delegate partyHostManagerUploadProgress:progress identifier:info.identifier];
    }

    if (sent == size) {
        PGLogDebug(@"PERIPHERAL: UPLOAD COMPLETE: STARTING DOWNLOAD");
        [self downloadImage:peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    PGLogDebug(@"PERIPHERAL: WROTE VALUE: %@: %@", characteristic.value, error);
}

#pragma mark - Utility

- (NSDictionary *)infoForPeripheral:(CBPeripheral *)peripheral
{
    return @{
             kPGPartyManagerPeripheralIdentifierKey: peripheral.identifier,
             kPGPartyManagerPeripheralNameKey: nil == peripheral.name ? kDefaultName : peripheral.name
             };
}

- (void)addPeripheral:(CBPeripheral *)peripheral
{
    [self removePeripheral:peripheral];
    [self.connectedPeripherals addObject:peripheral];
    peripheral.delegate = self;
}

- (void)removePeripheral:(CBPeripheral *)peripheral
{
    NSMutableArray *matches = [NSMutableArray array];
    for (CBPeripheral *existing in self.connectedPeripherals) {
        if ([peripheral.identifier isEqual:existing.identifier]) {
            [matches addObject:existing];
        }
    }
    [self.connectedPeripherals removeObjectsInArray:matches];
}

- (PGPartyFileInfo *)fileInfoForPeripheral:(CBPeripheral *)peripheral
{
    for (CBPeripheral *existing in self.downloads.keyEnumerator) {
        if ([peripheral.identifier isEqual:existing.identifier]) {
            return [self.downloads objectForKey:existing];
        }
    }
    return nil;
}

- (NSArray<NSDictionary *> *)connectedDevices
{
    if (nil == self.centralManager) {
        return @[];
    }
    
    NSMutableArray<NSDictionary *> *devices = [NSMutableArray array];
    for (CBPeripheral *peripheral in [self.centralManager retrieveConnectedPeripheralsWithServices:@[ [CBUUID UUIDWithString:kPGPartyManagerServiceUUID] ]]) {
        [devices addObject:[self infoForPeripheral:peripheral]];
    }
    return devices;
}

#pragma mark - Download Image

- (void)updateDownloadStats:(CBPeripheral *)peripheral
{
    @synchronized (self) {
        PGPartyFileInfo *info = [self fileInfoForPeripheral:peripheral];
        CBCharacteristic *characteristic = [[peripheral.services firstObject].characteristics firstObject];
        [peripheral writeValue:info.packet forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        NSUInteger received = [PGPartyFileInfo receivedFromPacket:info.packet];
        NSUInteger size = [PGPartyFileInfo sizeFromPacket:info.packet];
        PGLogDebug(@"DOWNLOAD: STATS: %lu: %@: %lu", (unsigned long)info.identifier, peripheral.identifier.UUIDString, (unsigned long)received);
        if ([self.delegate respondsToSelector:@selector(partyHostManagerDownloadProgress:identifier:)]) {
            CGFloat progress = (CGFloat)received / (CGFloat)size;
            [self.delegate partyHostManagerDownloadProgress:progress identifier:info.identifier];
        }
    }
}

- (void)downloadImage:(CBPeripheral *)peripheral
{
    PGPartyFileInfo *info = [self fileInfoForPeripheral:peripheral];
    PGLogDebug(@"DOWNLOAD: START: %lu: %@", (unsigned long)info.identifier, peripheral.identifier.UUIDString);
    [[PGPartyAWSTransfer sharedInstance] download:info progress:^(NSUInteger bytesReceived) {
        PGLogDebug(@"DOWNLOAD: PROGRESS: %lu: %@: %lu", (unsigned long)info.identifier, peripheral.identifier.UUIDString, (unsigned long)bytesReceived);
        info.received = bytesReceived;
        if (info.received < info.size) {
            [self updateDownloadStats:peripheral];
        }
    } completion:^(UIImage *image, NSError *error) {
        if (nil == error) {
            PGLogDebug(@"DOWNLOAD: COMPLETE: %lu: %@", (unsigned long)info.identifier, peripheral.identifier.UUIDString);
            info.received = info.size;
            [self updateDownloadStats:peripheral];
            if ([self.delegate respondsToSelector:@selector(partyHostManagerReceivedImage:fromPeripheral:)]) {
                [self.delegate partyHostManagerReceivedImage:image fromPeripheral:[self infoForPeripheral:peripheral]];
            }
        } else {
            PGLogError(@"DOWNLOAD ERROR: %@: %@", peripheral, error);
        }
    }];
}

#pragma mark - Notifications

- (void)handleSettingsChangedNotification:(NSNotification *)notification
{
    if (![PGFeatureFlag isPartyModeEnabled]) {
        self.scanning = NO;
    }
}

@end
