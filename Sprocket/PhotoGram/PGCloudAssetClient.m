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

#import "PGCloudAssetClient.h"
#import "PGCloudAssetStorage.h"
#import <AFNetworking.h>

static NSString * const kPGCloudAssetClientServerUrl = @"http://cloud-asset-service-int.us-west-2.elasticbeanstalk.com";
static NSString * const kPGCloudAssetClientCatalogPath = @"/catalogs/get_current_catalog.json";

@implementation PGCloudAssetClient

- (void)refreshAssetCatalog
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSString *stringUrl = [kPGCloudAssetClientServerUrl stringByAppendingString:kPGCloudAssetClientCatalogPath];
    NSURL *url = [NSURL URLWithString:stringUrl];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSLog(@"Refreshing Cloud Assets Catalog...");

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error) {
            NSArray *stickerCategoriesData = [responseObject objectForKey:@"sticker_categories"];
            NSMutableArray<PGCloudAssetCategory *> *stickerCategories = [[NSMutableArray alloc] init];

            for (NSDictionary *categoryData in stickerCategoriesData) {
                [stickerCategories addObject:[PGCloudAssetCategory categoryWithData:categoryData]];
            }

            NSArray<PGCloudAssetCategory *> *sorted = [stickerCategories sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                PGCloudAssetCategory *first = (PGCloudAssetCategory *)obj1;
                PGCloudAssetCategory *second = (PGCloudAssetCategory *)obj2;
                return [@(first.position) compare:@(second.position)];
            }];

            PGCloudAssetStorage *storage = [[PGCloudAssetStorage alloc] init];
            [storage storeStickerCatalog:sorted];

            NSLog(@"Refreshing Cloud Assets Catalog... Done!");
            NSLog(@"Downloading New Cloud Assets...");

            [self downloadAssetsForCurrentCatalog];
        }
    }];

    [dataTask resume];
}

- (NSArray<PGCloudAssetCategory *> *)currentStickersCatalog
{
    PGCloudAssetStorage *storage = [[PGCloudAssetStorage alloc] init];

    return [storage retrieveStickerCatalog];
}


#pragma mark - Private

- (void)downloadAssetsForCurrentCatalog
{
    PGCloudAssetStorage *storage = [[PGCloudAssetStorage alloc] init];

    NSArray<PGCloudAssetCategory *> *stickerCategories = [storage retrieveStickerCatalog];

    for (PGCloudAssetCategory *category in stickerCategories) {
        for (PGCloudAssetImage *asset in category.imageAssets) {
            [storage storeAsset:asset];
        }
    }
}

@end
