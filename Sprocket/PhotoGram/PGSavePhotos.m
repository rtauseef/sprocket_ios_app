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

#import "PGSavePhotos.h"
#import <HPPRCameraRollLoginProvider.h>

NSString * const kSettingSaveCameraPhotos = @"SettingSaveCameraPhotos";

@implementation PGSavePhotos

#pragma mark - Save Photos Methods


+ (void)saveVideo:(AVURLAsset *)asset completion:(void (^)(BOOL))completion {
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            NSString *albumTitle = @"sprocket";
            
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", albumTitle];
            PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
            
            if ([fetchResult firstObject]) {
                PHAssetCollection *sprocketAlbum = [fetchResult firstObject];
                
                [self saveVideo:asset toAssetCollection:sprocketAlbum completion:completion];
                
            } else {
                __block PHObjectPlaceholder *sprocketAlbumPlaceholder;
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumTitle];
                    sprocketAlbumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
                    
                } completionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[sprocketAlbumPlaceholder.localIdentifier] options:nil];
                        PHAssetCollection *sprocketAlbum = fetchResult.firstObject;
                        
                        [self saveVideo:asset toAssetCollection:sprocketAlbum completion:completion];
                    } else {
                        if (completion) {
                            completion(NO);
                        }
                    }
                }];
            }
            
        } else {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

+ (void)saveImage:(UIImage *)image completion:(void (^)(BOOL))completion
{
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            NSString *albumTitle = @"sprocket";
            
            PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", albumTitle];
            PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
            
            if ([fetchResult firstObject]) {
                PHAssetCollection *sprocketAlbum = [fetchResult firstObject];
                
                [self saveImage:image toAssetCollection:sprocketAlbum completion:completion];
                
            } else {
                __block PHObjectPlaceholder *sprocketAlbumPlaceholder;
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumTitle];
                    sprocketAlbumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
                    
                } completionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[sprocketAlbumPlaceholder.localIdentifier] options:nil];
                        PHAssetCollection *sprocketAlbum = fetchResult.firstObject;
                        
                        [self saveImage:image toAssetCollection:sprocketAlbum completion:completion];
                    } else {
                        if (completion) {
                            completion(NO);
                        }
                    }
                }];
            }
            
        } else {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

+ (void)saveImage:(UIImage *)image toAssetCollection:(PHAssetCollection *)assetCollection completion:(void (^)(BOOL))completion
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            completion(success);
        }
    }];
}

+ (void)saveVideo:(AVURLAsset *)video toAssetCollection:(PHAssetCollection *)assetCollection completion:(void (^)(BOOL))completion
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[video URL]];
        
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            completion(success);
        }
    }];
}

#pragma mark - Auto-Save Photo Setting

+ (BOOL)savePhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingSaveCameraPhotos];
}

+ (void)setSavePhotos:(BOOL)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:save forKey:kSettingSaveCameraPhotos];
    [defaults synchronize];
}

+ (BOOL)userPromptedToSavePhotos
{
    BOOL userPrompted = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kSettingSaveCameraPhotos]) {
        userPrompted = NO;
    }
    return userPrompted;
}

@end
