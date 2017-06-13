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

#import "HPPRCameraRollMedia.h"
#import "HPPRCameraRollLoginProvider.h"
#import "HPPRCameraRollPhotoProvider.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

const NSUInteger kHPPRCameraRollMediaThumbnailSize = 150;
const NSUInteger kHPPRCameraRollMediaPreviewSize = 500;

@interface HPPRCameraRollMedia()

@property (assign, nonatomic) PHImageRequestID lastImageRequestID;

@end

@implementation HPPRCameraRollMedia

- (id)initWithAsset:(PHAsset *)asset;
{
    self = [super init];
 
    if (self) {
        self.asset = asset;
        self.location = asset.location;
        self.createdTime = asset.creationDate;
    }

    return self;
}

- (void)requestThumbnailImageWithCompletion:(void(^)(UIImage *image))completion
{
    if (!self.thumbnailImage) {
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        requestOptions.synchronous = NO;
        requestOptions.networkAccessAllowed = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                                   targetSize:CGSizeMake(kHPPRCameraRollMediaThumbnailSize, kHPPRCameraRollMediaThumbnailSize)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:requestOptions
                                                resultHandler:^void(UIImage *image, NSDictionary *info) {
                                                    self.thumbnailImage = image;
                                                    if (completion) {
                                                        completion(self.thumbnailImage);
                                                    }
                                                }];
    } else if (completion) {
        completion(self.thumbnailImage);
    }
}

- (void)requestPreviewImageWithCompletion:(void(^)(UIImage *image))completion
{
    if (!self.previewImage) {
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.synchronous = NO;
        
        CGFloat size = kHPPRCameraRollMediaPreviewSize * [[UIScreen mainScreen] scale];
        self.lastImageRequestID = [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                                                         targetSize:CGSizeMake(size, size)
                                                                        contentMode:PHImageContentModeAspectFit
                                                                            options:requestOptions
                                                                      resultHandler:^void(UIImage *image, NSDictionary *info) {
                                                                          if ( ([info[PHImageResultRequestIDKey] integerValue] == self.lastImageRequestID || self.lastImageRequestID == 0) &&
                                                                              ![info[PHImageResultIsDegradedKey] boolValue] ) {
                                                                              self.lastImageRequestID = 0;
                                                                              self.previewImage = image;
                                                                              if (completion) {
                                                                                  completion(self.previewImage);
                                                                              }
                                                                          }
                                                                      }];
    } else if (completion) {
        completion(self.previewImage);
    }
}

- (void)requestImageWithCompletion:(void(^)(UIImage *image))completion
{
    if (!self.image) {
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        requestOptions.synchronous = NO;
        requestOptions.networkAccessAllowed = YES;
        
        self.lastImageRequestID = [[PHImageManager defaultManager] requestImageForAsset:self.asset
                                                   targetSize:PHImageManagerMaximumSize
                                                  contentMode:PHImageContentModeDefault
                                                      options:requestOptions
                                                resultHandler:^void(UIImage *image, NSDictionary *info) {
                                                    self.image = image;
                                                    if (completion) {
                                                        completion(self.image);
                                                    }
                                                }];
        
        PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
        options.networkAccessAllowed = YES;
        
        [self.asset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
            
            self.isoSpeed = fullImage.properties[@"{Exif}"][@"ISOSpeedRatings"];
            
            NSString *shutterSpeed = fullImage.properties[@"{Exif}"][@"ShutterSpeedValue"];
            
            // shutter speed formula: http://www.media.mit.edu/pia/Research/deepview/exif.html
            self.shutterSpeed = [NSString stringWithFormat:@"1/%.0f", pow(2,[shutterSpeed floatValue])];
        }];
    } else if (completion) {
        completion(self.image);
    }
}

- (void)cancelImageRequestWithCompletion:(void(^)())completion
{
    if (0 != self.lastImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.lastImageRequestID];
        self.lastImageRequestID = 0;
    }
    
    if (completion) {
        completion();
    }
}

- (BOOL)isEqualToMedia:(HPPRMedia *)media {
    BOOL isEqual = NO;

    if ([[media asset] localIdentifier]) {
        isEqual = [self.asset.localIdentifier isEqualToString:media.asset.localIdentifier];
    }

    return isEqual;
}

- (HPPRSelectPhotoProvider *)photoProvider {
    return [HPPRCameraRollPhotoProvider sharedInstance];
}

@end
