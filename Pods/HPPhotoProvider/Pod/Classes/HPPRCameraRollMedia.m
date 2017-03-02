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
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

const NSUInteger kHPPRCameraRollMediaThumbnailSize = 150;

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
                                                    completion(self.thumbnailImage);
                                                }];
    } else {
        completion(self.thumbnailImage);
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
                                                    if (image) {
                                                        self.image = image;
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
    } else {
        completion(self.image);
    }
}

- (void)cancelImageRequestWithCompletion:(void(^)())completion
{
    [[PHImageManager defaultManager] cancelImageRequest:self.lastImageRequestID];
    
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

@end
