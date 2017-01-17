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

typedef NS_ENUM (NSInteger, PGStickerItemsChinese){
    PGStickerItemsDragon2        =  0,
    PGStickerItemsHatWoman       =  1,
    PGStickerItemsFirecracker    =  2,
    PGStickerItemsHcny           =  3,
    PGStickerItemsPanda          =  4,
    PGStickerItemsHatMan         =  5,
    PGStickerItemsMustache1      =  6,
    PGStickerItemsHatWoman2      =  7,
    PGStickerItemsLionMask       =  8,
    PGStickerItemsGlassesBlossom =  9,
    PGStickerItemsGlasses2017    = 10,
    PGStickerItemsFish1          = 11,
    PGStickerItemsLuckyCat       = 12,
    PGStickerItemsLantern        = 13,
    PGStickerItemsFan            = 14,
    PGStickerItemsDuiLianCouplet = 15,
    PGStickerItemsFuGoodLuck     = 16,
    PGStickerItemsMoney          = 17,
    PGStickerItemsYinYang        = 18,
    PGStickerItemsRooster        = 19,
    PGStickerItemsOranges        = 20,
    PGStickerItemsPlumBlossom    = 21
};

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
    PGStickerItemsNewYearHorn       = 24
};

//typedef NS_ENUM (NSInteger, PGStickerItemsHoliday){
//    PGStickerItemsSnowman           =  0,
//    PGStickerItemsRudolphGlasses    =  1,
//    PGStickerItemsChristmasHat      =  2,
//    PGStickerItemsChristmasStar     =  3,
//    PGStickerItemsHanukkahGlasses   =  4,
//    PGStickerItemsSnowmanHat        =  5,
//    PGStickerItemsPartyHat          =  6,
//    PGStickerItemsTreeGlasses       =  7,
//    PGStickerItemsStarGlasses       =  8,
//    PGStickerItemsRudolphAntlers    =  9,
//    PGStickerItemsChristmasCap      = 10,
//    PGStickerItemsSnowmanFace       = 11,
//    PGStickerItemsChristmasScarf    = 12,
//    PGStickerItemsSnowflake         = 13,
//    PGStickerItemsStringOfLights    = 14,
//    PGStickerItemsChristmasTree     = 15,
//    PGStickerItemsChristmasStocking = 16,
//    PGStickerItemsCandyCane         = 17,
//    PGStickerItemsHolly             = 18,
//    PGStickerItemsMistletoe         = 19,
//    PGStickerItemsChristmasOrnament = 20,
//    PGStickerItemsMenorah           = 21,
//    PGStickerItemsDreidel           = 22,
//    PGStickerItemsFireworks         = 23,
//    PGStickerItemsNewYearHorn       = 24
//};

typedef NS_ENUM (NSInteger, PGStickerItemsValentines){
    PGStickerItemsValentinesXoxo                =  0,
    PGStickerItemsValentinesHeartFrame          =  1,
    PGStickerItemsValentinesHeartConfetti       =  2,
    PGStickerItemsValentinesConversationHeart   =  3,
    PGStickerItemsValentinesFlyingHeart         =  4,
    PGStickerItemsValentinesDeliveryBird        =  5,
    PGStickerItemsValentinesButterFly           =  6,
    PGStickerItemsValentinesHeartMonster        =  7,
    PGStickerItemsValentinesRoseBud             =  8,
    PGStickerItemsValentinesHeartBouquet        =  9,
    PGStickerItemsValentinesHeartGarland        =  10,
    PGStickerItemsValentinesPig                 =  11,
    PGStickerItemsValentinesHeartAntennae       =  12,
    PGStickerItemsValentinesHeartGlasses        =  13,
    PGStickerItemsValentinesHat                 =  14,
    PGStickerItemsValentinesHeartBow            =  15,
    PGStickerItemsValentinesHeartBalloons       =  16,
    PGStickerItemsValentinesHeartThought        =  17,
    PGStickerItemsValentinesLoveLetter          =  18,
    PGStickerItemsValentinesDancingHearts       =  19,
    PGStickerItemsValentinesLoveCreature        =  20,
    PGStickerItemsValentinesHeartArrow          =  21,
    PGStickerItemsValentinesHeartEmoji          =  22,
    PGStickerItemsValentinesHeartBanner         =  23,
    PGStickerItemsValentinesLockAndKey          =  24,
    PGStickerItemsValentinesCupcake             =  25,
    PGStickerItemsValentinesCat                 =  26,
    PGStickerItemsValentinesBrokenHeart         =  27,
    PGStickerItemsValentinesTargetHeart         =  28,
    PGStickerItemsValentinesHeartGlassesTwo     =  29,
    PGStickerItemsValentinesHeartTiara          =  30,
    PGStickerItemsValentinesFlowerCrown         =  31
};

typedef NS_ENUM (NSInteger, PGStickerItemsSuperBowl){
    PGStickerItemsSuperBowlGlasses              =  0,
    PGStickerItemsSuperBowlGlassesTwo           =  1,
    PGStickerItemsSuperBowlEyeBlack             =  2,
    PGStickerItemsSuperBowlFoamFinger           =  3,
    PGStickerItemsSuperBowlHeartFootball        =  4,
    PGStickerItemsSuperBowlBanner               =  5,
    PGStickerItemsSuperBowlFlag                 =  6,
    PGStickerItemsSuperBowlHeartFootballTwo     =  7,
    PGStickerItemsSuperBowlStarsNBalls          =  8,
    PGStickerItemsSuperBowlGameTime             =  9,
    PGStickerItemsSuperBowlFootballFlames       =  10,
    PGStickerItemsSuperBowlLove                 =  11,
    PGStickerItemsSuperBowlIHeartFootball       =  12,
    PGStickerItemsSuperBowlOwl                  =  13,
    PGStickerItemsSuperBowlGoalPost             =  14,
    PGStickerItemsSuperBowlHelmet               =  15,
};

typedef NS_ENUM (NSInteger, PGStickerItems){
    PGStickerItemsCatGlasses       = 0,
    PGStickerItemsCatWhiskers      = 1,
    PGStickerItemsCatEars          = 2,
    PGStickerItemsHearts           = 3,
    PGStickerItemsXoxo             = 4,
    PGStickerItemsHeartExpress     = 5,
    PGStickerItemsArrow            = 6,
    PGStickerItemsCrown            = 7,
    PGStickerItemsBirthdayHat      = 8,
    PGStickerItemsMoon             = 9,
    PGStickerItemsStar             = 10,
    PGStickerItemsStars            = 11,
    PGStickerItemsFeather2         = 12,
    PGStickerItemsFeather          = 13,
    PGStickerItemsLeaf3            = 14,
    PGStickerItemsCupcake          = 15,
    PGStickerItemsCat              = 16,
    PGStickerItemsDiamond          = 17,
    PGStickerItemsSunglasses       = 18,
    PGStickerItemsOMG              = 19
};

@interface PGStickerItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *name;

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index;
+ (PGStickerItem *)stickerByAccessibilityText:(NSString *)accessibilityText;
+ (NSInteger)stickerCount;
- (UIImage *)thumbnailImage;
- (UIImage *)stickerImage;

@end
