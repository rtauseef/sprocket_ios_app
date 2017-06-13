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

#import "HPPRCacheService.h"
#import <AssetsLibrary/AssetsLibrary.h>

NSString * const kCacheServiceAssetPrefix = @"assets-library://";
NSString * const kCacheServiceThumbnailSuffix = @"thumbnail";
NSString * const kCacheServiceErrorDomain = @"HPPRCacheService";
NSString * const kCacheServiceErrorURLKey = @"url";

typedef NS_ENUM(NSInteger, kCacheServiceError) {
    kCacheServiceErrorNoData = 100,
    kCacheServiceErrorInvalidParameters = 101
};

@interface HPPRCacheService()

@property (strong, nonatomic) ALAssetsLibrary *library;

@end

@implementation HPPRCacheService

+ (HPPRCacheService *)sharedInstance
{
    static dispatch_once_t once;
    static HPPRCacheService *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPRCacheService alloc] init];
        sharedInstance.library = [[ALAssetsLibrary alloc] init];
    });
    return sharedInstance;
}

- (UIImage *)imageForUrl:(NSString *)url
{
    UIImage *cacheImage = [self retrieveFromCacheWithKey:url];
    
    if (nil == cacheImage) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
        if (data) {
            cacheImage = [UIImage imageWithData:data];
            [self saveToCache:cacheImage withKey:url];
        }
    }
    
    return cacheImage;
}

- (void)imageForUrl:(NSString *)url asThumbnail:(BOOL)thumbnail withCompletion:(void(^)(UIImage *image, NSString *url, NSError *error))completion
{
    if (!url) {
        if (completion) {
            completion(nil, url, [NSError errorWithDomain:kCacheServiceErrorDomain code:kCacheServiceErrorInvalidParameters userInfo:nil]);
        }
        return;
    }
    
    NSString *key = thumbnail ? [NSString stringWithFormat:@"%@-%@", url, kCacheServiceThumbnailSuffix] : url;
    UIImage *cacheImage = [self retrieveFromCacheWithKey:key];
    
    if (cacheImage) {
        if (completion) {
            completion(cacheImage, url, nil);
        }
    } else {
        if (NSNotFound == [url rangeOfString:kCacheServiceAssetPrefix].location) {
            cacheImage = [self imageForUrl:url];
            if (cacheImage) {
                if (completion) {
                    completion(cacheImage, url, nil);
                }
            } else {
                if (completion) {
                    completion(nil, url, [NSError errorWithDomain:kCacheServiceErrorDomain code:kCacheServiceErrorNoData userInfo:@{ kCacheServiceErrorURLKey:url }]);
                }
            }
        } else {
            [self.library assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *asset) {
                UIImage *image;
                if (thumbnail) {
                    image = [UIImage imageWithCGImage:[asset thumbnail]];
                } else {
                    // Reference: http://biasedbit.com/alasset-image-orientation/
                    ALAssetRepresentation* representation = [asset defaultRepresentation];
                    NSNumber* orientationValue = [asset valueForProperty:ALAssetPropertyOrientation];
                    UIImageOrientation orientation = orientationValue ? [orientationValue intValue] : UIImageOrientationUp;
                    image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:1 orientation:orientation];
                }
                [self saveToCache:image withKey:key];
                if (completion) {
                    completion(image, url, nil);
                }
            } failureBlock:^(NSError *error) {
                if (completion) {
                    completion(nil, url, error);
                }
            }];
        }
    }
}

@end
