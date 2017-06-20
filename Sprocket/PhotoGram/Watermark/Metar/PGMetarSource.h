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

#import <Foundation/Foundation.h>
#import "PGMetarSocial.h"

typedef NS_ENUM(NSInteger, PGMetarSourceFrom) {
    PGMetarSourceFromUnknown,
    PGMetarSourceFromLocal,
    PGMetarSourceFromSocial,
    PGMetarSourceFromShared,
    PGMetarSourceFromMetar,
    PGMetarSourceFromOther
};

typedef NS_ENUM(NSInteger, PGMetarSourceOrigin) {
    PGMetarSourceOriginUnknown,
    PGMetarSourceOriginStorage,
    PGMetarSourceOriginOpenIn,
    PGMetarSourceOriginDownloaded
};

@interface PGMetarSource : NSObject

@property (assign, nonatomic) PGMetarSourceFrom from;
@property (assign, nonatomic) PGMetarSourceOrigin origin;
@property (strong, nonatomic) NSString* uri;
@property (strong, nonatomic) NSString* album;
@property (strong, nonatomic) PGMetarSocial* social;
@property (strong, nonatomic) NSString* identifier;
@property (strong, nonatomic) NSString* owner;
@property (strong, nonatomic) NSNumber* livePhoto;

- (instancetype)initWithDictionary: (NSDictionary *) dict;
- (NSDictionary *) getDict;

@end
