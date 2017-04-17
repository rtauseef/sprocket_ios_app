//
//  PGPayoffMetadata.m
//  Sprocket
//
//  Created by Bruno Dal Bo on 4/17/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPayoffMetadata.h"

NSString * const kPGPayoffMetadataURLKey = @"url";
NSString * const kPGPayoffTypeKey = @"type";
NSString * const kPGPayoffUUIDKey = @"uuid";
NSString * const kPGPayoffDataKey = @"data";

@implementation PGPayoffMetadata


- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = kPGPayoffNoType;
        self.offline = YES;
        [self generateId];
    }

    return self;
}


+(instancetype) offlinePayoffWithDictionary:(NSDictionary *) data {
    PGPayoffMetadata * ret = [[PGPayoffMetadata alloc] init];
    ret.uuid = data[kPGPayoffUUIDKey];
    if( ! ret.uuid ) {
        return nil;
    } else {
        ret.type = (tPGPayoffMetadataType) [data[kPGPayoffTypeKey] intValue];
        ret.data = data[kPGPayoffDataKey];
        ret.offline = YES;
        return ret;
    }
}

+ (instancetype)onlineURLPayoff:(NSURL *)url {
    PGPayoffMetadata * ret = [[PGPayoffMetadata alloc] init];
    ret.offline = NO;
    ret.type = kPGPayoffURL;
    ret.data = @{
            kPGPayoffMetadataURLKey : [url absoluteString]
    };

    return ret;
}

- (NSDictionary *)toDictionary {
    return @{
            kPGPayoffDataKey : self.data,
            kPGPayoffTypeKey : @(self.type),
            kPGPayoffUUIDKey : self.uuid
    };
}

- (NSURL *)URL {
    return [NSURL URLWithString:self.data[kPGPayoffMetadataURLKey]];
}


-(void) generateId {
    // creates new random ID
    self.uuid = [[NSUUID UUID] UUIDString];
}

+(instancetype) offlineVideoPayoffWithAsset:(NSURL*) asset {
    PGPayoffMetadata * ret = [[PGPayoffMetadata alloc] init];
    ret.type = kPGPayoffVideo;
    ret.offline = YES;
    ret.data = @{
                 kPGPayoffMetadataURLKey : [asset absoluteString]
    };
    return ret;
}

@end
