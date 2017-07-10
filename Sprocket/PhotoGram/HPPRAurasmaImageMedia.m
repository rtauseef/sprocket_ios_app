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

#import "HPPRAurasmaImageMedia.h"


const NSUInteger kHPPRAurasmaImageMediaThumbnailSize = 150;
const NSUInteger kHPPRAurasmaImageMediaPreviewSize = 500;

@implementation HPPRAurasmaImageMedia


- (id)initWithImage:(UIImage *)image andId:(NSString*)auraId
{
    self = [super init];
    
    if (self) {
        self.image = image;
        self.createdTime = [NSDate date];
    }
    
    return self;
}

- (void)requestThumbnailImageWithCompletion:(void(^)(UIImage *image))completion
{
    if (!self.thumbnailImage) {
        completion([HPPRAurasmaImageMedia imageWithImage:self.image
                                            scaledToSize:CGSizeMake(kHPPRAurasmaImageMediaThumbnailSize, kHPPRAurasmaImageMediaThumbnailSize)]);
    } else {
        completion(self.thumbnailImage);
    }
}

- (void)requestPreviewImageWithCompletion:(void(^)(UIImage *image))completion
{
    if (!self.previewImage) {
        
        CGFloat size = kHPPRAurasmaImageMediaPreviewSize * [[UIScreen mainScreen] scale];
        completion([HPPRAurasmaImageMedia imageWithImage:self.image
                                            scaledToSize:CGSizeMake(size, size)]);
    } else {
        completion(self.previewImage);
    }
}

- (void)requestImageWithCompletion:(void(^)(UIImage *image))completion
{
    completion(self.image);
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
