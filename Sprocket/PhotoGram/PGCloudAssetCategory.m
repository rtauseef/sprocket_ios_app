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

#import "PGCloudAssetCategory.h"

static NSString * const kPGCloudAssetCategoryId = @"kPGCloudAssetCategoryId";
static NSString * const kPGCloudAssetCategoryAnalyticsId = @"kPGCloudAssetCategoryAnalyticsId";
static NSString * const kPGCloudAssetCategoryTitle = @"kPGCloudAssetCategoryTitle";
static NSString * const kPGCloudAssetCategoryThumbnail = @"kPGCloudAssetCategoryThumbnail";
static NSString * const kPGCloudAssetCategoryImageAssets = @"kPGCloudAssetCategoryImageAssets";
static NSString * const kPGCloudAssetCategoryPosition = @"kPGCloudAssetCategoryPosition";

@implementation PGCloudAssetCategory

+ (instancetype)categoryWithData:(NSDictionary *)data
{
    PGCloudAssetCategory *category = [[PGCloudAssetCategory alloc] init];

    category.categoryId = [[data objectForKey:@"id"] integerValue];
    category.position = [[data objectForKey:@"position"] integerValue];
    category.analyticsId = [data objectForKey:@"analytics_id"];
    category.title = [data objectForKey:@"title"];

    category.thumbnailURL = [@"https:" stringByAppendingString:[data objectForKey:@"icon_url"]];

    NSArray *imageAssetsData = [data objectForKey:@"image_assets"];
    NSMutableArray<PGCloudAssetImage *> *imageAssets = [[NSMutableArray alloc] init];

    for (NSDictionary *assetData in imageAssetsData) {
        [imageAssets addObject:[PGCloudAssetImage assetWithData:assetData]];
    }

    // TODO: sort by position

    category.imageAssets = [imageAssets copy];

    return category;
}


#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.categoryId forKey:kPGCloudAssetCategoryId];
    [aCoder encodeInteger:self.position forKey:kPGCloudAssetCategoryPosition];
    [aCoder encodeObject:self.analyticsId forKey:kPGCloudAssetCategoryAnalyticsId];
    [aCoder encodeObject:self.title forKey:kPGCloudAssetCategoryTitle];
    [aCoder encodeObject:self.thumbnailURL forKey:kPGCloudAssetCategoryThumbnail];
    [aCoder encodeObject:self.imageAssets forKey:kPGCloudAssetCategoryImageAssets];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        self.categoryId = [aDecoder decodeIntegerForKey:kPGCloudAssetCategoryId];
        self.position = [aDecoder decodeIntegerForKey:kPGCloudAssetCategoryPosition];
        self.analyticsId = [aDecoder decodeObjectOfClass:[NSString class] forKey:kPGCloudAssetCategoryAnalyticsId];
        self.title = [aDecoder decodeObjectOfClass:[NSString class] forKey:kPGCloudAssetCategoryTitle];
        self.thumbnailURL = [aDecoder decodeObjectOfClass:[NSString class] forKey:kPGCloudAssetCategoryThumbnail];
        self.imageAssets = [aDecoder decodeObjectOfClass:[NSArray class] forKey:kPGCloudAssetCategoryImageAssets];
    }

    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end
