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

@interface PGPartyFileInfo : NSObject

@property (assign, nonatomic, readonly) NSUInteger identifier;
@property (assign, nonatomic, readonly) NSUInteger size;
@property (strong, nonatomic, readonly) NSData *data;
@property (assign, nonatomic) NSUInteger sent;
@property (assign, nonatomic) NSUInteger received;

- (instancetype)initWithIdentifier:(NSUInteger)identifier size:(NSUInteger)size;
- (instancetype)initWithIdentifier:(NSUInteger)identifier data:(NSData *)data;

- (NSData *)packet;

+ (NSUInteger)identifierFromPacket:(NSData *)packet;
+ (NSUInteger)sizeFromPacket:(NSData *)packet;
+ (NSUInteger)sentFromPacket:(NSData *)packet;
+ (NSUInteger)receivedFromPacket:(NSData *)packet;

@end
