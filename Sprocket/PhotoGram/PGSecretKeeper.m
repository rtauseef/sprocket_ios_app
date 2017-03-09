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

#import "PGSecretKeeper.h"
#import <CommonCrypto/CommonCrypto.h>

//
// How to set an obfuscated key
//
// 1 - Convert original key from ASCII to Hexadecimal. Use your preferred tool or www.asciitohex.com
// Ex: "asdf" => 61736466
//
// 2 - Obfuscate the Hex generated in the previous step by passing it through a XOR using the SHA1 for "PGSecretKeeper" as second input.
// SHA1 for "PGSecretKeeper" is 8abadb2d9de09df11a57e9c08b664f9574c639e4
// Use your preferred tool or xor.pw
// Ex: 61736466 XOR 8abadb2d9de09df11a57e9c08b664f9574c639e4 => 8abadb2d9de09df11a57e9c08b664f9515b55d82
//
// 3 - Expand the resulting obfuscated Hex in an unsigned char array. Remember to add 0x00 at the end as C arrays are null terminated
// Ex: { 0x8a, 0xba, 0xdb, 0x2d, ..., 0x00 }
//

unsigned char kObfuscatedEntryInstagramClientId[]           = { 0x35, 0x64, 0x62, 0x35, 0x64, 0x39, 0x32, 0x62, 0x33, 0x37, 0x66, 0x34, 0xbe, 0xdb, 0xbf, 0x15, 0xa4, 0x83, 0xa8, 0x93, 0x2c, 0x65, 0xd9, 0xa1, 0xb9, 0x02, 0x2c, 0xa2, 0x44, 0xfe, 0x08, 0x87, 0x00 }; //@"5db5d92b37f44ad89c5b620a2dc7081c";
unsigned char kObfuscatedEntryFlickrAppKey[]                = { 0x34, 0x38, 0x66, 0x65, 0x35, 0x33, 0x66, 0x32, 0x31, 0x34, 0x64, 0x65, 0xb9, 0x8e, 0xe9, 0x18, 0xac, 0x83, 0xaa, 0xc9, 0x29, 0x64, 0x8f, 0xa1, 0xba, 0x50, 0x78, 0xa0, 0x10, 0xf2, 0x5b, 0xd7, 0x00 }; //@"48fe53f214de34251c7833fa1675d4b3";
unsigned char kObfuscatedEntryFlickrAppSecret[]             = { 0x8a, 0xba, 0xdb, 0x2d, 0xa5, 0xd8, 0xab, 0xc4, 0x7b, 0x66, 0x8b, 0xf2, 0xed, 0x55, 0x78, 0xa1, 0x46, 0xf5, 0x0e, 0xd4, 0x00 }; //@"8865a1b2f3742370";
unsigned char kObfuscatedEntryQZoneAppId[]                  = { 0x8a, 0xba, 0xdb, 0x2d, 0x9d, 0xe0, 0x9d, 0xf1, 0x1a, 0x57, 0xe9, 0xf1, 0xbb, 0x57, 0x7c, 0xa3, 0x4c, 0xf2, 0x0c, 0xdd, 0x00 }; //@"101368459";
unsigned char kObfuscatedEntryGoogleAnalyticsTrakingId[]    = { 0x8a, 0xba, 0xdb, 0x2d, 0x9d, 0xe0, 0x9d, 0xa4, 0x5b, 0x7a, 0xd1, 0xf1, 0xb3, 0x53, 0x7d, 0xa0, 0x4c, 0xf3, 0x14, 0xd5, 0x00 }; //@"UA-81852585-1";
unsigned char kObfuscatedEntryGoogleAnalyticsTrakingIdDev[] = { 0x8a, 0xba, 0xdb, 0x2d, 0x9d, 0xe0, 0x9d, 0xa4, 0x5b, 0x7a, 0xd1, 0xf1, 0xb3, 0x53, 0x7d, 0xa0, 0x4c, 0xf3, 0x14, 0xd6, 0x00 }; //@"UA-81852585-2";
unsigned char kObfuscatedEntryCrashlyticsKey[]              = { 0x66, 0x65, 0x64, 0x31, 0x66, 0x65, 0x34, 0x65, 0x61, 0x38, 0x61, 0x34, 0x63, 0x35, 0x37, 0x37, 0x38, 0x66, 0x66, 0x30, 0xbd, 0x8f, 0xef, 0x4f, 0xfe, 0xd1, 0xa5, 0xc4, 0x2b, 0x31, 0xd1, 0xa6, 0xb3, 0x03, 0x29, 0xa2, 0x12, 0xf3, 0x5c, 0x80, 0x00 }; //@"fed1fe4ea8a4c5778ff0754bc1851f8f8ef7f5ed";


NSString * const kSecretKeeperEntryInstagramClientId           = @"kSecretKeeperEntryInstagramClientId";
NSString * const kSecretKeeperEntryFlickrAppKey                = @"kSecretKeeperEntryFlickrAppKey";
NSString * const kSecretKeeperEntryFlickrAppSecret             = @"kSecretKeeperEntryFlickrAppSecret";
NSString * const kSecretKeeperEntryQZoneAppId                  = @"kSecretKeeperEntryQZoneAppId";
NSString * const kSecretKeeperEntryGoogleAnalyticsTrakingId    = @"kSecretKeeperEntryGoogleAnalyticsTrakingId";
NSString * const kSecretKeeperEntryGoogleAnalyticsTrakingIdDev = @"kSecretKeeperEntryGoogleAnalyticsTrakingIdDev";
NSString * const kSecretKeeperEntryCrashlyticsKey              = @"kSecretKeeperEntryCrashlyticsKey";

@interface MPSecretKeeper ()

- (unsigned char *)byteArrayForEntry:(NSString *)entry;

@end

@implementation PGSecretKeeper

+ (instancetype)sharedInstance {
    static PGSecretKeeper *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[PGSecretKeeper alloc] init];
    });

    return instance;
}

- (unsigned char *)byteArrayForEntry:(NSString *)entry {
    if ([entry isEqualToString:kSecretKeeperEntryInstagramClientId]) {
        return kObfuscatedEntryInstagramClientId;
    }

    if ([entry isEqualToString:kSecretKeeperEntryFlickrAppKey]) {
        return kObfuscatedEntryFlickrAppKey;
    }

    if ([entry isEqualToString:kSecretKeeperEntryFlickrAppSecret]) {
        return kObfuscatedEntryFlickrAppSecret;
    }

    if ([entry isEqualToString:kSecretKeeperEntryQZoneAppId]) {
        return kObfuscatedEntryQZoneAppId;
    }

    if ([entry isEqualToString:kSecretKeeperEntryGoogleAnalyticsTrakingId]) {
        return kObfuscatedEntryGoogleAnalyticsTrakingId;
    }

    if ([entry isEqualToString:kSecretKeeperEntryGoogleAnalyticsTrakingIdDev]) {
        return kObfuscatedEntryGoogleAnalyticsTrakingIdDev;
    }

    if ([entry isEqualToString:kSecretKeeperEntryCrashlyticsKey]) {
        return kObfuscatedEntryCrashlyticsKey;
    }

    return [super byteArrayForEntry:entry];
}

@end
