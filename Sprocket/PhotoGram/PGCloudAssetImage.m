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

#import "PGCloudAssetImage.h"

static NSString * const kPGCloudAssetImageAssetId = @"kPGCloudAssetImageAssetId";
static NSString * const kPGCloudAssetImageVersion = @"kPGCloudAssetImageVersion";
static NSString * const kPGCloudAssetImageName = @"kPGCloudAssetImageName";
static NSString * const kPGCloudAssetImageAssetURL = @"kPGCloudAssetImageAssetURL";
static NSString * const kPGCloudAssetImageThumbnailURL = @"kPGCloudAssetImageThumbnailURL";
static NSString * const kPGCloudAssetImagePosition = @"kPGCloudAssetImagePosition";


@implementation PGCloudAssetImage

+ (instancetype)assetWithData:(NSDictionary *)data
{
    PGCloudAssetImage *asset = [[PGCloudAssetImage alloc] init];

    asset.assetId = [[data objectForKey:@"id"] integerValue];
    asset.version = [[data objectForKey:@"version_num"] integerValue];
    asset.position = [[data objectForKey:@"position"] integerValue];

    asset.name = [data objectForKey:@"asset_image_file_name"];

    NSDictionary *urls = [data objectForKey:@"s3_urls"];
    asset.assetURL = [@"https:" stringByAppendingString:[urls objectForKey:@"printable"]];
    asset.thumbnailURL = [@"https:" stringByAppendingString:[urls objectForKey:@"ios_large"]];

    return asset;
}


#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.assetId forKey:kPGCloudAssetImageAssetId];
    [aCoder encodeInteger:self.version forKey:kPGCloudAssetImageVersion];
    [aCoder encodeInteger:self.position forKey:kPGCloudAssetImagePosition];
    [aCoder encodeObject:self.name forKey:kPGCloudAssetImageName];
    [aCoder encodeObject:self.assetURL forKey:kPGCloudAssetImageAssetURL];
    [aCoder encodeObject:self.thumbnailURL forKey:kPGCloudAssetImageThumbnailURL];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        self.assetId = [aDecoder decodeIntegerForKey:kPGCloudAssetImageAssetId];
        self.version = [aDecoder decodeIntegerForKey:kPGCloudAssetImageVersion];
        self.position = [aDecoder decodeIntegerForKey:kPGCloudAssetImagePosition];
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:kPGCloudAssetImageName];
        self.assetURL = [aDecoder decodeObjectOfClass:[NSString class] forKey:kPGCloudAssetImageAssetURL];
        self.thumbnailURL = [aDecoder decodeObjectOfClass:[NSString class] forKey:kPGCloudAssetImageThumbnailURL];
    }

    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
