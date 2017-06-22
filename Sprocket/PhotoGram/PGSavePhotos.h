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
#import <Photos/Photos.h>

@interface PGSavePhotos : NSObject

+ (void)saveVideo:(AVURLAsset *)asset completion:(void (^)(BOOL, PHAsset*))completion;
+ (void)saveImage:(UIImage *)image toAssetCollection:(PHAssetCollection *)assetCollection completion:(void (^)(BOOL, PHAsset*))completion;
+ (void)saveImage:(UIImage *)image completion:(void (^)(BOOL, PHAsset*))completion;
+ (void)saveImageFake:(UIImage *)image completion:(void (^)(BOOL, PHAsset*))completion;

+ (BOOL)savePhotos;
+ (void)setSavePhotos:(BOOL)save;
+ (BOOL)userPromptedToSavePhotos;

@end
