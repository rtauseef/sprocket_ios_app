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
#import "PGCloudAssetCategory.h"

@interface PGCloudAssetStorage : NSObject

- (void)storeStickerCatalog:(NSArray<PGCloudAssetCategory *> *)catalog;
- (NSArray<PGCloudAssetCategory *> *)retrieveStickerCatalog;

- (void)storeAsset:(PGCloudAssetImage *)asset;

- (NSString *)localUrlForAsset:(PGCloudAssetImage *)asset;
- (NSString *)localThumbnailUrlForAsset:(PGCloudAssetImage *)asset;
- (NSString *)localPathForURL:(NSString *)url;
@end
