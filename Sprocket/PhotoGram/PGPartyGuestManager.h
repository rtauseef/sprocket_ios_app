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

@protocol PGPartyGuestManagerDelegate;

@interface PGPartyGuestManager : PGPartyManager

extern NSString * const kPGPartyGuestManagerErrorDomain;

@property (assign, nonatomic) BOOL advertising;
@property (assign, nonatomic, readonly) BOOL connected;
@property (weak, nonatomic) id<PGPartyGuestManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)sendImage:(UIImage *)image;
- (void)sendImage:(UIImage *)image progress:(void(^_Nullable)(double progress))progress completion:(void (^_Nullable)(NSError *error))completion;

@end

@protocol PGPartyGuestManagerDelegate <NSObject>

@optional

- (void)partyGuestManagerDidStartAdvertising;
- (void)partyGuestManagerDidStopAdvertising;
- (void)partyGuestManagerAdvertisingError:(NSError *)error;

- (void)partyGuestManagerDidConnectCentral;
- (void)partyGuestManagerDidDisconnectCentral;

- (void)partyGuestManagerHostReceivedImage:(UIImage *)image;

- (void)partyGuestManagerUploadProgress:(float)progress;
- (void)partyGuestManagerDownloadProgress:(float)progress;

@end
