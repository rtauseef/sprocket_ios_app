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

@protocol PGPartyHostManagerDelegate;

@interface PGPartyHostManager : PGPartyManager

extern NSString * const kPGPartyHostManagerErrorDomain;

extern NSString * const kPGPartyManagerPeripheralIdentifierKey;
extern NSString * const kPGPartyManagerPeripheralNameKey;

@property (assign, nonatomic) BOOL scanning;
@property (weak, nonatomic) id<PGPartyHostManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (NSArray<NSDictionary *> *)connectedDevices;

@end

@protocol PGPartyHostManagerDelegate <NSObject>

@optional

- (void)partyHostManagerDidStartScanning;
- (void)partyHostManagerDidStopScanning;
- (void)partyHostManagerScanningError:(NSError *)error;

- (void)partyHostManagerDidConnectPeripheral:(NSDictionary *)peripheral;
- (void)partyHostManagerDidDisconnectPeripheral:(NSDictionary *)peripheral error:(NSError *)error;
- (void)partyHostManagerPeripheralError:(NSDictionary *)peripheral error:(NSError *)error;

- (void)partyHostManagerReceivedImage:(UIImage *)image fromPeripheral:(NSDictionary *)peripheral;

- (void)partyHostManagerUploadProgress:(CGFloat)progress identifier:(NSUInteger)identifier;
- (void)partyHostManagerDownloadProgress:(CGFloat)progress identifier:(NSUInteger)identifier;

@end
