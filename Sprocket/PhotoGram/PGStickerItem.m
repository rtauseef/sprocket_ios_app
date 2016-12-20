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

static const NSInteger PGStickerItemsCountHoliday = 25;
static const NSInteger PGStickerItemsCountChinese = 22;
static const NSInteger PGStickerItemsCountStandard = 20;

@implementation PGStickerItem

+ (NSInteger)stickerCount
{
    NSInteger numStickers = (PGStickerItemsCountStandard + PGStickerItemsCountHoliday);
    
    if ([NSLocale isChinese]) {
        numStickers = (PGStickerItemsCountStandard + PGStickerItemsCountChinese);
    }
    return numStickers;
}

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = nil;
    NSInteger stickerOffset = 0;
    
    if ([NSLocale isChinese]) {
        sticker = [PGStickerItem chineseStickerItemByIndex:index];
        stickerOffset = PGStickerItemsCountChinese;
    } else {
        sticker = [PGStickerItem holidayStickerItemByIndex:index];
        stickerOffset = PGStickerItemsCountHoliday;
    }

    if (nil == sticker) {
        index -= stickerOffset;
        sticker = [[PGStickerItem alloc] init];
        
        switch (index) {
            case PGStickerItemsCatGlasses: {
                sticker.accessibilityText = @"Cat Glasses Sticker";
                sticker.imageName = @"catglasses";
                break;
            }
            case PGStickerItemsSunglasses: {
                sticker.accessibilityText = @"Sunglasses Sticker";
                sticker.imageName = @"sunglasses";
                break;
            }
            case PGStickerItemsHearts: {
                sticker.accessibilityText = @"Hearts Sticker";
                sticker.imageName = @"hearts";
                break;
            }
            case PGStickerItemsXoxo: {
                sticker.accessibilityText = @"XOXO Sticker";
                sticker.imageName = @"xoxo";
                break;
            }
            case PGStickerItemsHeartExpress: {
                sticker.accessibilityText = @"Heart Express Sticker";
                sticker.imageName = @"heartExpress";
                break;
            }
            case PGStickerItemsArrow: {
                sticker.accessibilityText = @"Arrow Sticker";
                sticker.imageName = @"arrow";
                break;
            }
            case PGStickerItemsCrown: {
                sticker.accessibilityText = @"Crown Sticker";
                sticker.imageName = @"crown";
                break;
            }
            case PGStickerItemsBirthdayHat: {
                sticker.accessibilityText = @"Birthday Hat Sticker";
                sticker.imageName = @"birthdayHat";
                break;
            }
            case PGStickerItemsCatEars: {
                sticker.accessibilityText = @"Cat Ears Sticker";
                sticker.imageName = @"catears";
                break;
            }
            case PGStickerItemsStar: {
                sticker.accessibilityText = @"Star Sticker";
                sticker.imageName = @"starhp";
                break;
            }
            case PGStickerItemsStars: {
                sticker.accessibilityText = @"Stars Sticker";
                sticker.imageName = @"stars";
                break;
            }
            case PGStickerItemsFeather: {
                sticker.accessibilityText = @"Feather Sticker";
                sticker.imageName = @"feather";
                break;
            }
            case PGStickerItemsFeather2: {
                sticker.accessibilityText = @"Feather 2 Sticker";
                sticker.imageName = @"feather2";
                break;
            }
            case PGStickerItemsCupcake: {
                sticker.accessibilityText = @"Cupcake Sticker";
                sticker.imageName = @"cupcake";
                break;
            }
            case PGStickerItemsCat: {
                sticker.accessibilityText = @"Cat Sticker";
                sticker.imageName = @"cat";
                break;
            }
            case PGStickerItemsDiamond: {
                sticker.accessibilityText = @"Diamond Sticker";
                sticker.imageName = @"diamond";
                break;
            }
            case PGStickerItemsOMG: {
                sticker.accessibilityText = @"OMG Sticker";
                sticker.imageName = @"OMG";
                break;
            }
            case PGStickerItemsCatWhiskers: {
                sticker.accessibilityText = @"Cat Whiskers Sticker";
                sticker.imageName = @"catwhiskers";
                break;
            }
            case PGStickerItemsMoon: {
                sticker.accessibilityText = @"Moon Sticker";
                sticker.imageName = @"moon";
                break;
            }
            case PGStickerItemsLeaf3: {
                sticker.accessibilityText = @"Leaf 3 Sticker";
                sticker.imageName = @"leaf3";
                break;
            }
                
            default:
                break;
        }
    }
    
    return sticker;
}

+ (PGStickerItem *)chineseStickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = [[PGStickerItem alloc] init];
    
    switch (index) {
        case PGStickerItemsDragon2: {
            sticker.accessibilityText = @"Chinese Dragon Sticker";
            sticker.imageName = @"dragon2";
            break;
        }
        case PGStickerItemsHatWoman: {
            sticker.accessibilityText = @"Chinese Woman Hat Sticker";
            sticker.imageName = @"hat_woman";
            break;
        }
        case PGStickerItemsFirecracker: {
            sticker.accessibilityText = @"Chinese Firecracker Sticker";
            sticker.imageName = @"firecracker";
            break;
        }
        case PGStickerItemsHcny: {
            sticker.accessibilityText = @"Chinese HCNY Sticker";
            sticker.imageName = @"hcny";
            break;
        }
        case PGStickerItemsPanda: {
            sticker.accessibilityText = @"Chinese Panda Sticker";
            sticker.imageName = @"Panda";
            break;
        }
        case PGStickerItemsHatMan: {
            sticker.accessibilityText = @"Chinese Man Hat Sticker";
            sticker.imageName = @"hat_man";
            break;
        }
        case PGStickerItemsMustache1: {
            sticker.accessibilityText = @"Chinese Mustache Sticker";
            sticker.imageName = @"mustache_1";
            break;
        }
        case PGStickerItemsHatWoman2: {
            sticker.accessibilityText = @"Chinese Woman Hat 2 Sticker";
            sticker.imageName = @"hat_woman2";
            break;
        }
        case PGStickerItemsLionMask: {
            sticker.accessibilityText = @"Chinese Lion Mask Sticker";
            sticker.imageName = @"lion_mask";
            break;
        }
        case PGStickerItemsGlassesBlossom: {
            sticker.accessibilityText = @"Chinese Glasses Blossom Sticker";
            sticker.imageName = @"glasses_blossom";
            break;
        }
        case PGStickerItemsGlasses2017: {
            sticker.accessibilityText = @"Chinese Glasses 2017 Sticker";
            sticker.imageName = @"glasses_2017";
            break;
        }
        case PGStickerItemsFish1: {
            sticker.accessibilityText = @"Chinese Fish Sticker";
            sticker.imageName = @"fish_1";
            break;
        }
        case PGStickerItemsLuckyCat: {
            sticker.accessibilityText = @"Chinese Lucky Cat Sticker";
            sticker.imageName = @"lucky_cat";
            break;
        }
        case PGStickerItemsLantern: {
            sticker.accessibilityText = @"Chinese Lantern Sticker";
            sticker.imageName = @"lantern";
            break;
        }
        case PGStickerItemsFan: {
            sticker.accessibilityText = @"Chinese Fan Sticker";
            sticker.imageName = @"fan";
            break;
        }
        case PGStickerItemsDuiLianCouplet: {
            sticker.accessibilityText = @"Chinese Dui Lian Couplet Sticker";
            sticker.imageName = @"dui_lian_couplet";
            break;
        }
        case PGStickerItemsFuGoodLuck: {
            sticker.accessibilityText = @"Chinese Fu Good Luck Sticker";
            sticker.imageName = @"fu_good_luck";
            break;
        }
        case PGStickerItemsMoney: {
            sticker.accessibilityText = @"Chinese Money Sticker";
            sticker.imageName = @"money";
            break;
        }
        case PGStickerItemsYinYang: {
            sticker.accessibilityText = @"Chinese Yin Yang Sticker";
            sticker.imageName = @"yinyang";
            break;
        }
        case PGStickerItemsRooster: {
            sticker.accessibilityText = @"Chinese Rooster Sticker";
            sticker.imageName = @"rooster";
            break;
        }
        case PGStickerItemsOranges: {
            sticker.accessibilityText = @"Chinese Oranges Sticker";
            sticker.imageName = @"oranges";
            break;
        }
        case PGStickerItemsPlumBlossom: {
            sticker.accessibilityText = @"Chinese Plum Blossom Sticker";
            sticker.imageName = @"plum_blossom";
            break;
        }
        default:
            sticker = nil;
            break;
    };
    
    return sticker;
}

+ (PGStickerItem *)holidayStickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = [[PGStickerItem alloc] init];
    
    switch (index) {
        case PGStickerItemsSnowman: {
            sticker.accessibilityText = @"Holiday Snowman Sticker";
            sticker.imageName = @"snowman";
            break;
        }
        case PGStickerItemsRudolphGlasses: {
            sticker.accessibilityText = @"Holiday Rudolph Glasses Sticker";
            sticker.imageName = @"glasses_rudolph";
            break;
        }
        case PGStickerItemsChristmasHat: {
            sticker.accessibilityText = @"Holiday Elf Hat Sticker";
            sticker.imageName = @"christmas_hat";
            break;
        }
        case PGStickerItemsChristmasStar: {
            sticker.accessibilityText = @"Holiday Star Sticker";
            sticker.imageName = @"star0";
            break;
        }
        case PGStickerItemsHanukkahGlasses: {
            sticker.accessibilityText = @"Holiday Hanukkah Glasses Sticker";
            sticker.imageName = @"glasses_hanukah";
            break;
        }
        case PGStickerItemsSnowmanHat: {
            sticker.accessibilityText = @"Holiday Snowman Hat Sticker";
            sticker.imageName = @"snowman_hat";
            break;
        }
        case PGStickerItemsPartyHat: {
            sticker.accessibilityText = @"Holiday Party Hat Sticker";
            sticker.imageName = @"Party-Hat";
            break;
        }
        case PGStickerItemsTreeGlasses: {
            sticker.accessibilityText = @"Holiday Tree Glasses Sticker";
            sticker.imageName = @"glasses_tree";
            break;
        }
        case PGStickerItemsStarGlasses: {
            sticker.accessibilityText = @"Holiday Star Glasses Sticker";
            sticker.imageName = @"glasses_star";
            break;
        }
        case PGStickerItemsRudolphAntlers: {
            sticker.accessibilityText = @"Holiday Rudolph Antlers Sticker";
            sticker.imageName = @"rudolph_antlers";
            break;
        }
        case PGStickerItemsChristmasCap: {
            sticker.accessibilityText = @"Holiday Christmas Cap Sticker";
            sticker.imageName = @"cap";
            break;
        }
        case PGStickerItemsSnowmanFace: {
            sticker.accessibilityText = @"Holiday Snowman Face Sticker";
            sticker.imageName = @"snowman_face";
            break;
        }
        case PGStickerItemsChristmasScarf: {
            sticker.accessibilityText = @"Holiday Christmas Scarf Sticker";
            sticker.imageName = @"scarf";
            break;
        }
        case PGStickerItemsSnowflake: {
            sticker.accessibilityText = @"Holiday Snowflake Sticker";
            sticker.imageName = @"snowflake_2";
            break;
        }
        case PGStickerItemsStringOfLights: {
            sticker.accessibilityText = @"Holiday Lights Sticker";
            sticker.imageName = @"StringOLights";
            break;
        }
        case PGStickerItemsChristmasTree: {
            sticker.accessibilityText = @"Holiday Christmas Tree Sticker";
            sticker.imageName = @"tree";
            break;
        }
        case PGStickerItemsChristmasStocking: {
            sticker.accessibilityText = @"Holiday Christmas Stocking Sticker";
            sticker.imageName = @"stocking";
            break;
        }
        case PGStickerItemsCandyCane: {
            sticker.accessibilityText = @"Holiday Candy Cane Sticker";
            sticker.imageName = @"candy_cane";
            break;
        }
        case PGStickerItemsHolly: {
            sticker.accessibilityText = @"Holiday Holly Sticker";
            sticker.imageName = @"holly";
            break;
        }
        case PGStickerItemsMistletoe: {
            sticker.accessibilityText = @"Holiday Mistletoe Sticker";
            sticker.imageName = @"mistletoe";
            break;
        }
        case PGStickerItemsChristmasOrnament: {
            sticker.accessibilityText = @"Holiday Christmas Ornament Sticker";
            sticker.imageName = @"ornament_1";
            break;
        }
        case PGStickerItemsMenorah: {
            sticker.accessibilityText = @"Holiday Menorah Sticker";
            sticker.imageName = @"menorah";
            break;
        }
        case PGStickerItemsDreidel: {
            sticker.accessibilityText = @"Holiday Dreidel Sticker";
            sticker.imageName = @"dreidle";
            break;
        }
        case PGStickerItemsFireworks: {
            sticker.accessibilityText = @"Holiday Fireworks Sticker";
            sticker.imageName = @"fireworks";
            break;
        }
        case PGStickerItemsNewYearHorn: {
            sticker.accessibilityText = @"Holiday Horn Sticker";
            sticker.imageName = @"horn";
            break;
        }
        default:
            sticker = nil;
            break;
    };

    return sticker;
}

- (UIImage *)thumbnailImage {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_TN", self.imageName]];
}

- (UIImage *)stickerImage {
    return [UIImage imageNamed:self.imageName];
}

@end
