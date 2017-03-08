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

unsigned char kSecretEntryInstagramClientId[] = { 0x35, 0x64, 0x62, 0x35, 0x64, 0x39, 0x32, 0x62, 0x33, 0x37, 0x66, 0x34, 0xbe, 0xdb, 0xbf, 0x15, 0xa4, 0x83, 0xa8, 0x93, 0x2c, 0x65, 0xd9, 0xa1, 0xb9, 0x02, 0x2c, 0xa2, 0x44, 0xfe, 0x08, 0x87, 0x00 }; //@"5db5d92b37f44-ad89c5b620a2dc7081c";

@interface PGSecretKeeper ()

@property (nonnull, strong) NSCache *secretCache;

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

- (instancetype)init {
    self = [super init];

    if (self) {
        self.secretCache = [[NSCache alloc] init];
    }

    return self;
}

- (NSString *)secretForEntry:(SecretKeeperEntry)entry {
    NSString *secret = [self.secretCache objectForKey:@(entry)];

    if (secret) {
        return secret;
    }

    return [self clarifyEntry:kSecretEntryInstagramClientId];
}

- (NSString *)clarifyEntry:(unsigned char *)entry {
    unsigned char obfuscator[CC_SHA1_DIGEST_LENGTH];
    NSData *className = [NSStringFromClass([self class]) dataUsingEncoding:NSUTF8StringEncoding];

    CC_SHA1(className.bytes, (CC_LONG)className.length, obfuscator);

    NSData *obfuscatorKeyData = [NSData dataWithBytes:obfuscator length:CC_SHA1_DIGEST_LENGTH];
    NSData *obfuscatedData = [NSData dataWithBytes:entry length:(int)strlen((char *)entry)];

    NSData *clarifiedData = [self xor:obfuscatedData with:obfuscatorKeyData];

    return [[NSString alloc] initWithData:clarifiedData encoding:NSUTF8StringEncoding];
}

- (NSData *)xor:(NSData *)data1 with:(NSData *)data2 {
    NSData *shorterData = data2;
    NSData *longerData = data1;

    if (data1.length <= data2.length) {
        shorterData = data1;
        longerData = data2;
    }

    char *shorterBytes = (char *)shorterData.bytes;
    char *longerBytes = (char *)longerData.bytes;

    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:longerData.length];

    NSUInteger lengthPadding = longerData.length - shorterData.length;

    for (int i = 0; i < longerData.length; i++) {
        if (i < lengthPadding) {
            [data appendBytes:&longerBytes[i] length:1];
        } else {
            const char byte = shorterBytes[i - lengthPadding] ^ longerBytes[i];
            [data appendBytes:&byte length:1];
        }
    }

    return data;
}

@end
