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
#import "HPPRCameraRollPhotoProvider.h"

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
        self.mediaType = [HPPRCameraRollMedia mediaTypeForAsset:asset];
        self.objectID = [self.asset localIdentifier];
        
        if (self.asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
            self.livePhoto = [NSNumber numberWithBool:YES];
        } else {
            self.livePhoto = [NSNumber numberWithBool:NO];
        }
    }

    return self;
}

+ (HPPRMediaType)mediaTypeForAsset:(PHAsset*)asset {
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        return HPPRMediaTypeVideo;
    } else {
        return HPPRMediaTypeImage; // default to image if it's not video. audio possibility is "gracefully ignored" =)
    }
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
            
            if (self.mediaType == HPPRMediaTypeImage)  {
                CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
                
                id isoInfo =  fullImage.properties[@"{Exif}"][@"ISOSpeedRatings"];
                
                if ([isoInfo isKindOfClass:[NSArray class]]) {
                    self.isoSpeed = [(NSArray *) isoInfo firstObject];
                } else if ([isoInfo isKindOfClass:[NSString class]]) {
                    self.isoSpeed = isoInfo;
                }
                
                NSString *shutterSpeed = fullImage.properties[@"{Exif}"][@"ShutterSpeedValue"];
                
                // shutter speed formula: http://www.media.mit.edu/pia/Research/deepview/exif.html
                self.shutterSpeed = [NSString stringWithFormat:@"1/%.0f", pow(2,[shutterSpeed floatValue])];
                
                self.exposureTime = fullImage.properties[@"{Exif}"][@"ExposureTime"];
                self.aperture = fullImage.properties[@"{Exif}"][@"ApertureValue"];
                
                NSNumber *flashDetails = fullImage.properties[@"{Exif}"][@"Flash"];
                if (flashDetails != nil) {
                    
                    int flash = [flashDetails intValue];
                    if (flash != 0 && flash != 16 && flash != 24 && flash != 32) {
                        self.flash = [NSNumber numberWithBool:YES];
                    } else {
                        self.flash = [NSNumber numberWithBool:NO];
                    }
                }

                self.focalLength = fullImage.properties[@"{Exif}"][@"FocalLength"];
                self.cameraMake = fullImage.properties[@"{TIFF}"][@"Make"];
                self.cameraModel = fullImage.properties[@"{TIFF}"][@"Model"];
            } else if (self.mediaType == HPPRMediaTypeVideo) {
                AVAsset *resolvedAsset = contentEditingInput.avAsset;
                
                CMTime duration = [resolvedAsset duration];
                Float64 time = CMTimeGetSeconds(duration);
                self.videoDuration = [NSNumber numberWithFloat:time];
            }
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
