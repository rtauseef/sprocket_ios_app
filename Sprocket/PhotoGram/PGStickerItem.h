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

typedef NS_ENUM (NSInteger, PGStickerItemsFall){
    PGStickerItemsPumpkin    =  0,
    PGStickerItemsFootball   =  1,
    PGStickerItemsBanner2    =  2,
    PGStickerItemsFox        =  3,
    PGStickerItemsPilgrimHat =  4,
    PGStickerItemsWomanHat   =  5,
    PGStickerItemsEyes2      =  6,
    PGStickerItemsLips       =  7,
    PGStickerItemsTurkeyHat2 =  8,
    PGStickerItemsLeaves     =  9,
    PGStickerItemsHedgehog   = 10,
    PGStickerItemsMushroomsB = 11,
    PGStickerItemsPie        = 12,
    PGStickerItemsCocoa      = 13,
};

typedef NS_ENUM (NSInteger, PGStickerItems){
    PGStickerItemsCatGlasses       = 14,
    PGStickerItemsCatWhiskers      = 15,
    PGStickerItemsCatEars          = 16,
    PGStickerItemsHearts           = 17,
    PGStickerItemsXoxo             = 18,
    PGStickerItemsHeartExpress     = 19,
    PGStickerItemsArrow            = 20,
    PGStickerItemsCrown            = 21,
    PGStickerItemsBirthdayHat      = 22,
    PGStickerItemsMoon             = 23,
    PGStickerItemsStar             = 24,
    PGStickerItemsStars            = 25,
    PGStickerItemsFeather2         = 26,
    PGStickerItemsFeather          = 27,
    PGStickerItemsLeaf3            = 28,
    PGStickerItemsCupcake          = 29,
    PGStickerItemsCat              = 30,
    PGStickerItemsDiamond          = 31,
    PGStickerItemsSunglasses       = 32,
    PGStickerItemsOMG              = 33,
};

@interface PGStickerItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index;
- (UIImage *)thumbnailImage;
- (UIImage *)stickerImage;

@end
