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

#import "HPPRCameraRollPhotoProvider.h"
#import "HPPRCameraRollLoginProvider.h"
#import "HPPRCameraRollMedia.h"
#import "NSBundle+HPPRLocalizable.h"
#import <Photos/Photos.h>


@interface HPPRCameraRollPhotoProvider()

@property (strong, nonatomic) PHAssetCollection *assetCollection;

@end

@implementation HPPRCameraRollPhotoProvider

int const kPhotosPerRequest = 50;

#pragma mark - Initialization

+ (HPPRCameraRollPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRCameraRollPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRCameraRollPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRCameraRollLoginProvider sharedInstance];
    });
    return sharedInstance;
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Camera Roll";
}

- (NSString *)localizedName
{
    return HPPRLocalizedString(@"Camera Roll", @"Name of the camera roll app of the device");
}

- (BOOL)showSearchButton
{
    return NO;
}

- (BOOL)showNetworkWarning
{
    return NO;
}

- (NSString *)titleText
{
    return [NSString stringWithFormat:HPPRLocalizedString(@"%@ Photos", @"Photos of the specified social network"), self.name];
}

- (NSString *)headerText
{
    NSMutableString *text = [NSMutableString stringWithFormat:@"%@", self.album.name];
    NSUInteger count = self.album.photoCount;
    
    if (1 == count) {
        [text appendString:HPPRLocalizedString(@" (1 photo)", nil)];
    } else {
        [text appendFormat:HPPRLocalizedString(@" (%lu photos)", @"Number of photos"), (unsigned long)count];
    }
    
    return [NSString stringWithString:text];
}

#pragma mark - Photo list operations

- (void)requestImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    NSArray *records = [self getThumbnailPhotosFromCameraRoll];
    completion(@{ @"data":records });
}

#pragma mark - Albums and photos


- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion
{
    [self getThumbnailPhotosFromCameraRoll];
    
    completion(nil);
}

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES],];
    
    PHFetchResult *cameraRollAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
    
    NSMutableArray *albums = [NSMutableArray array];
    [cameraRollAlbum enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        [self addAlbum:collection toArray:albums];
    }];
    
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        if (collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            [self addAlbum:collection toArray:albums];
        }
    }];
    
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        [self addAlbum:collection toArray:albums];
    }];
    
    completion(albums, nil);
}

- (void)addAlbum:(PHAssetCollection *)collection toArray:(NSMutableArray *)albums
{
    PHFetchResult *fetchPhotosResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    
    HPPRAlbum *album = [[HPPRAlbum alloc] init];
    album.assetCollection = collection;
    album.photoCount = [fetchPhotosResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    
    if (album.photoCount > 0) {
        [albums addObject:album];
    }
}

- (NSArray *)getThumbnailPhotosFromCameraRoll
{
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = nil;
    
    if (self.album.assetCollection) {
        result = [PHAsset fetchAssetsInAssetCollection:self.album.assetCollection options:allPhotosOptions];
    } else {
        result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    }
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:result.count];
    
    for (PHAsset *asset in result) {
        [images addObject:[[HPPRCameraRollMedia alloc] initWithAsset:asset]];
    }
    
    [self replaceImagesWithRecords:images];
    
    return images;
}

@end
