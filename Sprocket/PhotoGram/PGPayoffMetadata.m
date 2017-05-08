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

#import "PGPayoffMetadata.h"
#import "HPPRMedia.h"

NSString * const kPGPayoffMetadataURLKey = @"url";
NSString * const kPGPayoffMetadataAssetIdentifierKey = @"phasset-id";
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

+(instancetype)metaFromHPPRMedia: (HPPRMedia *) media {
    if( media.socialMediaImageUrl ) {
        return [self onlineURLPayoff:[NSURL URLWithString:media.socialMediaImageUrl]];
    } else if (media.asset && media.asset.mediaType == PHAssetMediaTypeVideo) {
        return [self offlineVideoPayoffWithAsset:media.asset];
    } else {
        return nil;
    }
}

+(instancetype)offlinePayoffFromDictionary:(NSDictionary *) data {
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

- (NSString *)assetIdentifier {
    return self.data[kPGPayoffMetadataAssetIdentifierKey];
}

- (PHAsset*)fetchPHAsset {
    NSString * id = self.assetIdentifier;
    if( id ) {
        PHFetchOptions * options = [PHFetchOptions new];
        PHFetchResult *  res = [PHAsset fetchAssetsWithLocalIdentifiers:@[id] options:options];
        if( res.count > 0 ) {
            return [res objectAtIndex:0];
        }
    }

    return nil;


}


-(void) generateId {
    // creates new random ID
    self.uuid = [[NSUUID UUID] UUIDString];
}

+(instancetype) offlineVideoPayoffWithAsset:(PHAsset*) asset; {
    PGPayoffMetadata * ret = [[PGPayoffMetadata alloc] init];
    ret.type = kPGPayoffVideo;
    ret.offline = YES;
    ret.data = @{
            kPGPayoffMetadataAssetIdentifierKey : asset.localIdentifier
    };
    return ret;
}

@end
