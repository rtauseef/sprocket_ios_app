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

#import <AssetsLibrary/AssetsLibrary.h>
#import "HPPRCameraRollPhotoProvider.h"
#import "HPPRCameraRollLoginProvider.h"
#import "HPPRCameraRollAlbum.h"
#import "HPPRCameraRollMedia.h"
#import "NSBundle+HPPRLocalizable.h"


@interface HPPRCameraRollPhotoProvider()

@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSNumber *nextIndex;

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
        sharedInstance.library = [[ALAssetsLibrary alloc] init];
        sharedInstance.nextIndex = nil;
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
    if(reload) {
        self.nextIndex = nil;
    }

    
    if (nil == self.album  ||  nil == self.album.objectID) {
        [self albumsWithRefresh:NO andCompletion:^(NSArray *albums, NSError *error) {
            HPPRCameraRollAlbum *allPhotosAlbum = nil;
            for (HPPRCameraRollAlbum *album in albums) {
                if (nil == allPhotosAlbum || allPhotosAlbum.photoCount < album.photoCount) {
                    allPhotosAlbum = album;
                }
            }
            self.album = allPhotosAlbum;
            [self requestAlbmumImagesWithCompletion:completion andReloadAll:reload];
        }];
    } else {
        [self requestAlbmumImagesWithCompletion:completion andReloadAll:reload];
    }
}

#pragma mark - Albums and photos

- (void)requestAlbmumImagesWithCompletion:(void (^)(NSArray *records))completion andReloadAll:(BOOL)reload
{
    [self photosForAlbum:self.album.objectID withRefresh:YES andPaging:[self.nextIndex stringValue] andCompletion:^(NSDictionary *photos, NSError *error) {
        NSArray *records = [photos objectForKey:@"data"];
        if (reload) {
            [self replaceImagesWithRecords:records];
        } else {
            [self updateImagesWithRecords:records];
        }
        if (completion) {
            completion(records);
        }
    }];
}

- (void)refreshAlbumWithCompletion:(void (^)(NSError *error))completion
{
    [self.library groupForURL:[NSURL URLWithString:self.album.objectID] resultBlock:^(ALAssetsGroup *group) {
        
        // This is the case when the album was deleted
        if (group == nil) {
            if (completion) {
                completion([HPPRAlbum albumDeletedError]);
            }
        } else {
            [((HPPRCameraRollAlbum *)self.album) setAAssetGroup:group];
            
            if (completion) {
                completion(nil);
            }
        }
    } failureBlock:^(NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)albumsWithRefresh:(BOOL)refresh andCompletion:(void (^)(NSArray *albums, NSError *error))completion
{
    NSMutableArray *albums = [NSMutableArray array];
    NSUInteger types = ALAssetsGroupAlbum + ALAssetsGroupSavedPhotos;
    [self.library enumerateGroupsWithTypes:types usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (nil == group) {
            if (completion) {
                completion([self sortedAlbums:albums], nil);
            }
        } else {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [albums addObject:[[HPPRCameraRollAlbum alloc] initWithAssetGroup:group]];
        }
    } failureBlock:^(NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (NSArray *)sortedAlbums:(NSArray *)albums
{
    return [albums sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ALAssetsGroup *group1 = [obj1 group];
        ALAssetsGroup *group2 = [obj2 group];
        NSString *name1 = [group1 valueForProperty:ALAssetsGroupPropertyName];
        NSString *name2 = [group2 valueForProperty:ALAssetsGroupPropertyName];
        ALAssetsGroupType type1 = [[group1 valueForProperty:ALAssetsGroupPropertyType] integerValue];
        ALAssetsGroupType type2 = [[group2 valueForProperty:ALAssetsGroupPropertyType] integerValue];
        if (ALAssetsGroupSavedPhotos == type1) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (ALAssetsGroupSavedPhotos == type2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return [name1 caseInsensitiveCompare:name2];
    }];
}

- (void)photosForAlbum:(NSString *)albumID withRefresh:(BOOL)refresh andPaging:(NSString *)afterID andCompletion:(void (^)(NSDictionary *photos, NSError *error))completion
{
    [self.library groupForURL:[NSURL URLWithString:albumID] resultBlock:^(ALAssetsGroup *group) {
        NSMutableArray *photos = [NSMutableArray array];
        NSInteger startIndex = (nil == afterID) ? 0 : [afterID integerValue];
        NSInteger endIndex = MIN(startIndex + kPhotosPerRequest, group.numberOfAssets - 1);
        
        NSInteger reverseStart = group.numberOfAssets - endIndex - 1;
        NSInteger reverseEnd = group.numberOfAssets - startIndex - 1;
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(reverseStart, reverseEnd - reverseStart + 1)];
        [group enumerateAssetsAtIndexes:indexes options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (nil == result) {
                self.nextIndex = (endIndex >= group.numberOfAssets -1) ? nil : [NSNumber numberWithInteger:endIndex + 1];
                if (completion) {
                    completion(@{ @"data":[self sortedPhotos:photos] }, nil);
                }
            } else {
                [photos addObject:[[HPPRCameraRollMedia alloc] initWithAsset:result]];
            }
        }];
    } failureBlock:^(NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (NSArray *)sortedPhotos:(NSArray *)photos
{
    return [photos sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        HPPRCameraRollMedia *media1 = obj1;
        HPPRCameraRollMedia *media2 = obj2;
        
        if ([media1.createdTime compare:media2.createdTime] == NSOrderedDescending) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ([media1.createdTime compare:media2.createdTime] == NSOrderedAscending) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
}

- (BOOL)hasMoreImages
{
    return self.nextIndex != nil;
}

@end
