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

#import "PGPhotoSelection.h"
#import "PGMediaNavigation.h"

NSString * const kSettingSaveCameraPhotos = @"SettingSaveCameraPhotos";

static NSUInteger const kPhotoSelectionMaxSelected = 10;

@interface PGPhotoSelection ()

@property (nonatomic, assign) BOOL selectionEnabled;
@property (nonatomic, strong) NSMutableArray<HPPRMedia *> *selectedItems;

@end

@implementation PGPhotoSelection

+ (instancetype)sharedInstance {
    static PGPhotoSelection *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PGPhotoSelection alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.selectedItems = [[NSMutableArray<HPPRMedia *> alloc] init];
    }

    return self;
}

- (void)beginSelectionMode {
    self.selectionEnabled = YES;

    [[PGMediaNavigation sharedInstance] beginSelectionMode];
    [[PGMediaNavigation sharedInstance] updateSelectedItemsCount:self.selectedItems.count];
}

- (void)endSelectionMode {
    self.selectionEnabled = NO;
    [self.selectedItems removeAllObjects];

    [[PGMediaNavigation sharedInstance] endSelectionMode];
}

- (BOOL)isInSelectionMode {
    return self.selectionEnabled;
}

- (BOOL)isMaxedOut {
    return self.selectedItems.count >= kPhotoSelectionMaxSelected;
}

- (BOOL)hasMultiplePhotos
{
    return self.selectedItems.count > 1;
}

- (void)selectMedia:(HPPRMedia *)media {
    if (!self.isInSelectionMode) {
        [self.selectedItems removeAllObjects];
    }
    
    if (![self isSelected:media] && ![self isMaxedOut]) {
        [self.selectedItems addObject:media];
    }
}

- (void)deselectMedia:(HPPRMedia *)media {
    HPPRMedia *mediaToRemove;

    for (HPPRMedia *item in self.selectedItems) {
        if ([item isEqualToMedia:media]) {
            mediaToRemove = item;
            break;
        }
    }

    if (mediaToRemove) {
        [self.selectedItems removeObject:mediaToRemove];
    }
}

- (NSArray<HPPRMedia *> *)selectedMedia {
    return [NSArray<HPPRMedia *> arrayWithArray:self.selectedItems];
}

- (BOOL)isSelected:(HPPRMedia *)media {
    for (HPPRMedia *item in self.selectedItems) {
        if ([item isEqualToMedia:media]) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Save Photos Methods

- (void)savePhotosByGesturesView:(NSArray<PGGesturesView *> *)gesturesView completion:(void (^)(BOOL))completion
{
    NSUInteger count = 0;
    for (PGGesturesView *gestureView in gesturesView) {
        if (gestureView.isSelected) {
            [self saveImage:self.selectedItems[count].image completion:nil];
        }
        
        count++;
        
        if (count == self.selectedItems.count) {
            completion(YES);
        }
    }
}

- (void)saveImage:(UIImage *)image completion:(void (^)(BOOL))completion
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

- (void)saveImage:(UIImage *)image toAssetCollection:(PHAssetCollection *)assetCollection completion:(void (^)(BOOL))completion
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

#pragma mark - Auto-Save Photo Setting

- (BOOL)savePhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:kSettingSaveCameraPhotos];
}

- (void)setSavePhotos:(BOOL)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:save forKey:kSettingSaveCameraPhotos];
    [defaults synchronize];
}

- (BOOL)userPromptedToSavePhotos
{
    BOOL userPrompted = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kSettingSaveCameraPhotos]) {
        userPrompted = NO;
    }
    return userPrompted;
}

@end
