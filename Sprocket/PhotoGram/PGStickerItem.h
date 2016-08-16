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

extern const NSInteger PGStickerItemsCount;

typedef NS_ENUM (NSInteger, PGStickerItems){
    PGStickerItemsCatGlasses,
    PGStickerItemsSunglasses,
    PGStickerItemsHearts,
    PGStickerItemsXoxo,
    PGStickerItemsHeartExpress,
    PGStickerItemsHeartPixel,
    PGStickerItemsArrow,
    PGStickerItemsCrown,
    PGStickerItemsBirthdayHat,
    PGStickerItemsCatEars,
    PGStickerItemsStar,
    PGStickerItemsStars,
    PGStickerItemsFeather,
    PGStickerItemsFeather2,
    PGStickerItemsCloud,
    PGStickerItemsCupcake,
    PGStickerItemsIceCreamCone,
    PGStickerItemsCandy,
    PGStickerItemsCat,
    PGStickerItemsBird,
    PGStickerItemsDiamond,
    PGStickerItemsOMG,
    PGStickerItemsLOL
};


@interface PGStickerItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index;
- (UIImage *)thumbnailImage;
- (UIImage *)stickerImage;

@end
