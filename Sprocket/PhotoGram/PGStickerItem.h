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

typedef NS_ENUM (NSInteger, PGStickerItemsNapaValley){
    PGStickerItemsNapaValleyLoveHP  = 45,
};

typedef NS_ENUM (NSInteger, PGStickerItemsFall){
    PGStickerItemsFallCatWhiskers  = 1,
    PGStickerItemsFallDodMask      = 2,
    PGStickerItemsFallCatEyes      = 3,
    PGStickerItemsFallJasonMask    = 4,
    PGStickerItemsFallDodEyes      = 5,
    PGStickerItemsFall3Eyes        = 6,
    PGStickerItemsFallFangs        = 7,
    PGStickerItemsFallEyeball      = 8,
    
    PGStickerItemsFallDevilHorns   = 10,
    
    PGStickerItemsFallHalloweenHat = 18,
    PGStickerItemsFallSpiderWeb    = 19,
    PGStickerItemsFallMoon         = 20,
    PGStickerItemsFallMoonFace     = 21,
    
    PGStickerItemsFallSkull        = 24,
    PGStickerItemsFallPumpkin      = 25,
    PGStickerItemsFallBat          = 26,
    PGStickerItemsFallGhost        = 27,
    PGStickerItemsFallCandyCorn    = 28,
    PGStickerItemsFallSpider       = 29,
    PGStickerItemsFallScaryCat     = 30,
    
    PGStickerItemsFallLeaf3        = 34,
    PGStickerItemsFallOwl          = 35,
};

typedef NS_ENUM (NSInteger, PGStickerItems){
    PGStickerItemsCatGlasses   = 0,
    PGStickerItemsSunglasses   = 42,
    
    PGStickerItemsHearts       = 11,
    PGStickerItemsXoxo         = 12,
    PGStickerItemsHeartExpress = 13,
    PGStickerItemsHeartPixel   = 14,
    PGStickerItemsArrow        = 15,
    PGStickerItemsCrown        = 16,
    PGStickerItemsBirthdayHat  = 17,
    
    PGStickerItemsCatEars      = 9,
    
    PGStickerItemsStar         = 22,
    PGStickerItemsStars        = 23,
    
    PGStickerItemsFeather      = 33,
    
    PGStickerItemsFeather2     = 32,
    
    PGStickerItemsCloud        = 31,
    
    PGStickerItemsCupcake      = 36,
    PGStickerItemsIceCreamCone = 37,
    PGStickerItemsCandy        = 38,
    PGStickerItemsCat          = 39,
    PGStickerItemsBird         = 40,
    PGStickerItemsDiamond      = 41,
    
    PGStickerItemsOMG          = 43,
    PGStickerItemsLOL          = 44
};


@interface PGStickerItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index;
- (UIImage *)thumbnailImage;
- (UIImage *)stickerImage;

@end
