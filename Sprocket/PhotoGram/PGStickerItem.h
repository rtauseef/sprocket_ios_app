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

typedef NS_ENUM (NSInteger, PGStickerItemsHoliday){
    PGStickerItemsSnowman           =  0,
    PGStickerItemsRudolphGlasses    =  1,
    PGStickerItemsChristmasHat      =  2,
    PGStickerItemsChristmasStar     =  3,
    PGStickerItemsHanukkahGlasses   =  4,
    PGStickerItemsSnowmanHat        =  5,
    PGStickerItemsPartyHat          =  6,
    PGStickerItemsTreeGlasses       =  7,
    PGStickerItemsStarGlasses       =  8,
    PGStickerItemsRudolphAntlers    =  9,
    PGStickerItemsChristmasCap      = 10,
    PGStickerItemsSnowmanFace       = 11,
    PGStickerItemsChristmasScarf    = 12,
    PGStickerItemsSnowflake         = 13,
    PGStickerItemsStringOfLights    = 14,
    PGStickerItemsChristmasTree     = 15,
    PGStickerItemsChristmasStocking = 16,
    PGStickerItemsCandyCane         = 17,
    PGStickerItemsHolly             = 18,
    PGStickerItemsMistletoe         = 19,
    PGStickerItemsChristmasOrnament = 20,
    PGStickerItemsMenorah           = 21,
    PGStickerItemsDreidel           = 22,
    PGStickerItemsFireworks         = 23,
    PGStickerItemsNewYearHorn       = 24,
};

typedef NS_ENUM (NSInteger, PGStickerItems){
    PGStickerItemsCatGlasses       = 25,
    PGStickerItemsCatWhiskers      = 26,
    PGStickerItemsCatEars          = 27,
    PGStickerItemsHearts           = 28,
    PGStickerItemsXoxo             = 29,
    PGStickerItemsHeartExpress     = 30,
    PGStickerItemsArrow            = 31,
    PGStickerItemsCrown            = 32,
    PGStickerItemsBirthdayHat      = 33,
    PGStickerItemsMoon             = 34,
    PGStickerItemsStar             = 35,
    PGStickerItemsStars            = 36,
    PGStickerItemsFeather2         = 37,
    PGStickerItemsFeather          = 38,
    PGStickerItemsLeaf3            = 39,
    PGStickerItemsCupcake          = 40,
    PGStickerItemsCat              = 41,
    PGStickerItemsDiamond          = 42,
    PGStickerItemsSunglasses       = 43,
    PGStickerItemsOMG              = 44,
};

@interface PGStickerItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index;
- (UIImage *)thumbnailImage;
- (UIImage *)stickerImage;

@end
