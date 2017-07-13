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

#import "PGPartyFileInfo.h"

@implementation PGPartyFileInfo

- (instancetype)initWithIdentifier:(NSUInteger)identifier size:(NSUInteger)size
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _size = size;
        _data = [NSData data];
        self.sent = 0;
        self.received = 0;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSUInteger)identifier data:(NSData *)data
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _size = data.length;
        _data = data;
        self.sent = 0;
        self.received = 0;
    }
    return self;
}

#pragma mark - Data Packet

- (NSData *)packet
{
    Byte bytes[16];
    
    bytes[0] = (self.identifier >> 24) & 0xFF;
    bytes[1] = (self.identifier >> 16) & 0xFF;
    bytes[2] = (self.identifier >> 8) & 0xFF;
    bytes[3] = self.identifier & 0xFF;
    
    bytes[4] = (self.size >> 24) & 0xFF;
    bytes[5] = (self.size >> 16) & 0xFF;
    bytes[6] = (self.size >> 8) & 0xFF;
    bytes[7] = self.size & 0xFF;
    
    bytes[8] = (self.sent >> 24) & 0xFF;
    bytes[9] = (self.sent >> 16) & 0xFF;
    bytes[10] = (self.sent >> 8) & 0xFF;
    bytes[11] = self.sent & 0xFF;
    
    bytes[12] = (self.received >> 24) & 0xFF;
    bytes[13] = (self.received >> 16) & 0xFF;
    bytes[14] = (self.received >> 8) & 0xFF;
    bytes[15] = self.received & 0xFF;
    
    return [NSData dataWithBytes:bytes length:16];
}

+ (NSUInteger)valueForBytes:(Byte *)bytes
{
    return bytes[0] * pow(256, 3) + bytes[1] * pow(256, 2) + bytes[2] * 256 + bytes[3];
}

+ (NSUInteger)identifierFromPacket:(NSData *)packet
{
    Byte bytes[4];
    [packet getBytes:bytes range:NSMakeRange(0, 4)];
    return [self valueForBytes:bytes];
}

+ (NSUInteger)sizeFromPacket:(NSData *)packet
{
    Byte bytes[4];
    [packet getBytes:bytes range:NSMakeRange(4, 4)];
    return [self valueForBytes:bytes];
}

+ (NSUInteger)sentFromPacket:(NSData *)packet
{
    Byte bytes[4];
    [packet getBytes:bytes range:NSMakeRange(8, 4)];
    return [self valueForBytes:bytes];
}

+ (NSUInteger)receivedFromPacket:(NSData *)packet
{
    Byte bytes[4];
    [packet getBytes:bytes range:NSMakeRange(12, 4)];
    return [self valueForBytes:bytes];
}

@end
