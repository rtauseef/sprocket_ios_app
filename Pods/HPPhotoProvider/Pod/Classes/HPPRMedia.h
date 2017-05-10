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
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>

typedef enum {
    kHPRMediaTypeImage,
    kHPRMediaTypeVideo
} tHPRMediaType;

@class HPPRSelectPhotoProvider;

@interface HPPRMedia : NSObject

@property (nonatomic, strong) NSString *objectID;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userProfilePicture;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *standardUrl;
@property (nonatomic, strong) NSString *socialMediaImageUrl;
@property (assign, nonatomic) tHPRMediaType mediaType;

@property (nonatomic, strong) PHAsset *asset;
@property (strong, nonatomic) AVURLAsset *assetURL;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) NSUInteger likes;
@property (nonatomic, assign) NSUInteger comments;

@property (nonatomic, strong) NSDate *createdTime;

@property (nonatomic, strong) NSString *text;

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLPlacemark *place;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSArray *additionalLocations;

@property (strong, nonatomic) NSString* city;
@property (strong, nonatomic) NSString* country;
@property (strong, nonatomic) NSString* state;
@property (strong, nonatomic) NSString* street;
@property (strong, nonatomic) NSString* zip;

@property (nonatomic, strong) NSString *isoSpeed;
@property (nonatomic, strong) NSString *shutterSpeed;
@property (strong, nonatomic) NSNumber *exposureTime;
@property (strong, nonatomic) NSNumber *aperture;
@property (strong, nonatomic) NSNumber *flash;
@property (strong, nonatomic) NSNumber *focalLength;
@property (nonatomic, strong) NSString *cameraMake;
@property (nonatomic, strong) NSString *cameraModel;

@property (strong, nonatomic) NSNumber *videoDuration;


- (id)initWithAttributes:(NSDictionary *)attributes;
- (void)requestThumbnailImageWithCompletion:(void(^)(UIImage *image))completion;
- (void)requestPreviewImageWithCompletion:(void(^)(UIImage *image))completion;
- (void)requestImageWithCompletion:(void(^)(UIImage *image))completion;
- (void)cancelImageRequestWithCompletion:(void(^)())completion;
- (BOOL)isEqualToMedia:(HPPRMedia *)media;

- (HPPRSelectPhotoProvider *)photoProvider;

- (void)clearCachedImages;

@end
