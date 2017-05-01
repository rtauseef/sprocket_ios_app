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

#import "PGStickerItem.h"
#import "NSLocale+Additions.h"


@implementation PGStickerItem

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName  tintMode:(IMGLYStickerTintMode)tintMode andPackageName:(NSString *)packageName
{
    self = [super init];
    if (self) {
        NSString *stickerName = nil;
        if (packageName) {
            stickerName = [NSString stringWithFormat:@"%@ %@ Sticker", packageName, name];
        } else {
            stickerName = [NSString stringWithFormat:@"%@ Sticker", name];
        }
        
        self.name = stickerName;
        self.imageName = imageName;
        self.tintMode = tintMode;
    }
    return self;
}


- (UIImage *)thumbnailImage
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_TN", self.imageName]];
}

- (UIImage *)stickerImage
{
    return [UIImage imageNamed:self.imageName];
}

- (NSURL *)thumbnailURL {
    return [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@_TN", self.imageName] withExtension:@"png"];
}

- (NSURL *)imageURL {
    return [[NSBundle mainBundle] URLForResource:self.imageName withExtension:@"png"];
}

- (IMGLYSticker *)imglySticker {
    IMGLYSticker *imglySticker = [[IMGLYSticker alloc] initWithImageURL:[self imageURL]
                                                           thumbnailURL:[self thumbnailURL]
                                                               tintMode:[self tintMode]];
    imglySticker.accessibilityLabel = self.name;

    return imglySticker;
}

@end
