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
#import "PGAnalyticsManager.h"
#import <HPPRCameraRollLoginProvider.h>

NSString * const kSettingSaveCameraPhotos = @"SettingSaveCameraPhotos";

@implementation PGSavePhotos

#pragma mark - Save Photos Methods


+ (void)saveVideo:(AVURLAsset *)asset completion:(void (^)(BOOL, PHAsset*))completion {
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
                            completion(NO, nil);
                        }
                    }
                }];
            }
            
        } else {
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}

+ (void)saveImage:(UIImage *)image completion:(void (^)(BOOL, PHAsset*))completion
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
                            completion(NO,nil);
                        }
                    }
                }];
            }
            
        } else {
            if (completion) {
                completion(NO,nil);
            }
        }
    }];
}


+ (void)saveImageFake:(UIImage *)image completion:(void (^)(BOOL, PHAsset*))completion
{
    [[HPPRCameraRollLoginProvider sharedInstance] loginWithCompletion:^(BOOL loggedIn, NSError *error) {
        if (loggedIn) {
            NSString *albumTitle = @"sprocket-metar";
            
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
                            completion(NO,nil);
                        }
                    }
                }];
            }
            
        } else {
            if (completion) {
                completion(NO,nil);
            }
        }
    }];
}

+ (void)saveImage:(UIImage *)image toAssetCollection:(PHAssetCollection *)assetCollection completion:(void (^)(BOOL, PHAsset*))completion
{
    __block NSString* localId;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        
        localId = [[assetChangeRequest placeholderForCreatedAsset] localIdentifier];
    } completionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            
            PHFetchResult* assetResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
            PHAsset *asset = [assetResult firstObject];
            
            completion(success, asset);
        }
    }];
}

+ (void)saveVideo:(AVURLAsset *)video toAssetCollection:(PHAssetCollection *)assetCollection completion:(void (^)(BOOL, PHAsset*))completion
{
    __block NSString* localId;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[video URL]];
        
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        
        localId = [[assetChangeRequest placeholderForCreatedAsset] localIdentifier];
    } completionHandler:^(BOOL success, NSError *error) {
        if (completion) {
            PHFetchResult* assetResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
            PHAsset *asset = [assetResult firstObject];
            
            completion(success, asset);
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
    
    [[PGAnalyticsManager sharedManager] trackCameraAutoSavePreferenceActivity:(save ? @"On" : @"Off")];
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

+ (void)promptToSavePhotos:(UIViewController *)viewController completion:(void(^)(BOOL savePhotos))completion
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Auto-Save Settings", @"Settings for automatically saving photos")
                                                                   message:NSLocalizedString(@"Do you want to save new camera photos to your device?", @"Asks the user if they want their photos saved")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"Dismisses dialog without taking action")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [PGSavePhotos setSavePhotos:NO];
                                                         if (completion) {
                                                             completion(NO);
                                                         }
                                                     }];
    [alert addAction:noAction];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Dismisses dialog, and chooses to save photos")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          [PGSavePhotos setSavePhotos:YES];
                                                          if (completion) {
                                                              completion(YES);
                                                          }
                                                      }];
    [alert addAction:yesAction];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
