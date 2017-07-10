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

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "MPBTSprocketDefinitions.h"
#import "MPPrintItem.h"

extern NSString * kPGSettingsForceFirmwareUpgrade;
extern NSString * kPGUseExperimentalFirmware;

@protocol MPBTSprocketDelegate;

@interface MPBTSprocket : NSObject

@property (strong, nonatomic) EAAccessory *accessory;

+ (MPBTSprocket *)sharedInstance;

@property (weak, nonatomic) id<MPBTSprocketDelegate> delegate;

@property (strong, nonatomic) NSString *protocolString;
@property (assign, nonatomic) SprocketAutoPowerOffInterval powerOffInterval;
@property (assign, nonatomic) SprocketPrintMode printMode;
@property (assign, nonatomic) NSUInteger totalPrintCount;
@property (assign, nonatomic) NSUInteger batteryStatus;
@property (strong, nonatomic) NSData *macAddress;
@property (assign, nonatomic) NSUInteger firmwareVersion;
@property (assign, nonatomic) NSUInteger hardwareVersion;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSDictionary *analytics;

- (void)refreshInfo;
- (void)printImage:(UIImage *)image numCopies:(NSInteger)numCopies;
- (void)printItem:(MPPrintItem *)printItem numCopies:(NSInteger)numCopies;
- (void)reflash;

+ (NSArray *)pairedSprockets;
+ (NSString *)displayNameForAccessory:(EAAccessory *)accessory;
+ (BOOL)supportedAccessory:(EAAccessory *)accessory;
+ (NSString *)macAddress:(NSData *)data;
+ (NSString *)version:(NSUInteger)version;
+ (NSString *)errorTitleKey:(SprocketError)error;
+ (NSString *)errorTitle:(SprocketError)error;
+ (NSString *)errorDescription:(SprocketError)error;
+ (NSString *)autoPowerOffIntervalString:(SprocketAutoPowerOffInterval)interval;
+ (BOOL) forceFirmwareUpdates;
+ (void) setForceFirmwareUpdates:(BOOL)force;
+ (BOOL) useExperimentalFirmware;
+ (void) setUseExperimentalFirmware:(BOOL)useExperimental;

@end

@protocol MPBTSprocketDelegate <NSObject>

@optional
- (void)didRefreshSprocketInfo:(MPBTSprocket *)sprocket error:(SprocketError)error;
- (void)didSendPrintData:(MPBTSprocket *)sprocket percentageComplete:(NSInteger)percentageComplete error:(SprocketError)error;
- (void)didFinishSendingPrint:(MPBTSprocket *)sprocket;
- (void)didStartPrinting:(MPBTSprocket *)sprocket;
- (void)didReceiveError:(MPBTSprocket *)sprocket error:(SprocketError)error;
- (void)didSetAccessoryInfo:(MPBTSprocket *)sprocket error:(SprocketError)error;
- (void)didDownloadDeviceUpgradeData:(MPBTSprocket *)sprocket percentageComplete:(NSInteger)percentageComplete;
- (void)didSendDeviceUpgradeData:(MPBTSprocket *)sprocket percentageComplete:(NSInteger)percentageComplete error:(SprocketError)error;
- (void)didFinishSendingDeviceUpgrade:(MPBTSprocket *)sprocket;
- (void)didChangeDeviceUpgradeStatus:(MPBTSprocket *)sprocket status:(SprocketUpgradeStatus)status;
- (void)didCompareWithLatestFirmwareVersion:(MPBTSprocket *)sprocket needsUpgrade:(BOOL)needsUpgrade;

@end
