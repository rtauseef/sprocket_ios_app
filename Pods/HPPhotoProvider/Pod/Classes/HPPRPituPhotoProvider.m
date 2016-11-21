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

#import "HPPRPituPhotoProvider.h"
#import "HPPRPituLoginProvider.h"
#import "HPPRPituMedia.h"
#import "NSBundle+HPPRLocalizable.h"

@implementation HPPRPituPhotoProvider

#pragma mark - Initialization

+ (HPPRPituPhotoProvider *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRPituPhotoProvider *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRPituPhotoProvider alloc] init];
        sharedInstance.loginProvider = [HPPRPituLoginProvider sharedInstance];
        
        [sharedInstance albumsWithRefresh:NO andCompletion:^(NSArray *albums, NSError *error) {
            if (nil != albums  &&  1 == albums.count) {
                sharedInstance.album = albums[0];
            }
        }];
    });
    return sharedInstance;
}

#pragma mark - User Interface

- (NSString *)name
{
    return @"Pitu";
}

- (NSString *)localizedName
{
    return HPPRLocalizedString(@"Pitu", @"Name of the Pitu app/social media provider");
}

- (BOOL)showSearchButton
{
    return NO;
}

- (BOOL)showNetworkWarning
{
    return NO;
}

#pragma mark - Albums and photos

- (void)addAlbum:(PHAssetCollection *)collection toArray:(NSMutableArray *)albums
{
    PHFetchResult *fetchPhotosResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    
    if ([collection.localizedTitle isEqualToString:[self localizedName]]) {
        HPPRAlbum *album = [[HPPRAlbum alloc] init];
        album.assetCollection = collection;
        album.photoCount = [fetchPhotosResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        
        if (album.photoCount > 0) {
            [albums addObject:album];
        }
    } else {
        NSLog(@"Pitu rejecting folder %@", collection.localizedTitle);
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
        [images addObject:[[HPPRPituMedia alloc] initWithAsset:asset]];
    }
    
    [self replaceImagesWithRecords:images];
    
    return images;
}

@end
