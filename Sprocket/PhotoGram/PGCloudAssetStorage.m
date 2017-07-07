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

#import "PGCloudAssetStorage.h"
#import "PGCloudAssetDownloadWorker.h"
#import "NSString+Utils.h"
#import <AFNetworking/AFImageDownloader.h>

static NSString * const kPGCloudAssetStorageDirectory = @"CAS";
static NSString * const kPGCloudAssetStorageStickersDirectory = @"stickers";
static NSString * const kPGCloudAssetStorageStickerCatalogFileName = @"sticker-catalog.obj";

@implementation PGCloudAssetStorage

- (void)storeStickerCatalog:(NSArray<PGCloudAssetCategory *> *)catalog
{
    NSString *fileName = [[self storageRootPath] stringByAppendingPathComponent:kPGCloudAssetStorageStickerCatalogFileName];
    [NSKeyedArchiver archiveRootObject:catalog toFile:fileName];
}

- (NSArray<PGCloudAssetCategory *> *)retrieveStickerCatalog {
    NSString *fileName = [[self storageRootPath] stringByAppendingPathComponent:kPGCloudAssetStorageStickerCatalogFileName];
    NSData *data = [NSData dataWithContentsOfFile:fileName];

    NSArray<PGCloudAssetCategory *> *unarchivedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    return unarchivedObject;
}

- (void)storeAsset:(PGCloudAssetImage *)asset
{
    NSString *thumbnailPath = [self localThumbnailUrlForAsset:asset];
    [self storeURL:asset.thumbnailURL atPath:thumbnailPath];

    NSString *assetPath = [self localUrlForAsset:asset];
    [self storeURL:asset.assetURL atPath:assetPath];
}

- (NSString *)localUrlForAsset:(PGCloudAssetImage *)asset
{
    return [self localPathForURL:asset.assetURL];
}

- (NSString *)localThumbnailUrlForAsset:(PGCloudAssetImage *)asset
{
    return [self localPathForURL:asset.thumbnailURL];
}

- (NSString *)localPathForURL:(NSString *)url
{
    NSString *directoryPath = [self stickersRootPath];
    NSString *path = [directoryPath stringByAppendingPathComponent:[url md5]];
    path = [path stringByAppendingPathExtension:@"png"];

    return path;
}


#pragma mark - Private

- (NSString *)storageRootPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *storageRootPath = [documentsDirectory stringByAppendingPathComponent:kPGCloudAssetStorageDirectory];

    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:storageRootPath isDirectory:NULL];

    if (!pathExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:storageRootPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }

    return storageRootPath;
}

- (NSString *)stickersRootPath
{
    NSString *directoryPath = [[self storageRootPath] stringByAppendingPathComponent:kPGCloudAssetStorageStickersDirectory];

    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:NULL];

    if (!pathExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }

    return directoryPath;
}

- (void)storeURL:(NSString *)url atPath:(NSString *)path
{
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL];

    if (!pathExists) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [[AFImageDownloader defaultInstance] downloadImageForURLRequest:request
                                                                success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                                                                    if (response) {
                                                                        [UIImagePNGRepresentation(responseObject) writeToFile:path atomically:YES];
                                                                        NSLog(@"Cloud Asset downloaded!");
                                                                    }
                                                                }
                                                                failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                                    NSLog(@"DOWNLOAD FAILED - %@\n%@", error, response);
                                                                }];
    }
}

@end
