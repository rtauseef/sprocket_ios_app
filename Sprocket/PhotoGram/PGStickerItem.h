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

const NSInteger PGStickerItemsCount = 5;

typedef NS_ENUM (NSInteger, PGStickerItems){
    PGStickerItemsCatGlasses,
    PGStickerItemsCrown,
    PGStickerItemsHearts,
    PGStickerItemsOMG,
    PGStickerItemsStar
};


@interface PGStickerItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index;
- (UIImage *)thumbnailImage;
- (UIImage *)stickerImage;

@end
