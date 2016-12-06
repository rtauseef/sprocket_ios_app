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
                sticker.accessibilityText = NSLocalizedString(@"Cat Glasses Sticker", nil);
                sticker.imageName = @"catglasses";
                break;
            }
            case PGStickerItemsSunglasses: {
                sticker.accessibilityText = NSLocalizedString(@"Sunglasses Sticker", nil);
                sticker.imageName = @"sunglasses";
                break;
            }
            case PGStickerItemsHearts: {
                sticker.accessibilityText = NSLocalizedString(@"Hearts Sticker", nil);
                sticker.imageName = @"hearts";
                break;
            }
            case PGStickerItemsXoxo: {
                sticker.accessibilityText = NSLocalizedString(@"XOXO Sticker", nil);
                sticker.imageName = @"xoxo";
                break;
            }
            case PGStickerItemsHeartExpress: {
                sticker.accessibilityText = NSLocalizedString(@"Heart Express Sticker", nil);
                sticker.imageName = @"heartExpress";
                break;
            }
            case PGStickerItemsArrow: {
                sticker.accessibilityText = NSLocalizedString(@"Arrow Sticker", nil);
                sticker.imageName = @"arrow";
                break;
            }
            case PGStickerItemsCrown: {
                sticker.accessibilityText = NSLocalizedString(@"Crown Sticker", nil);
                sticker.imageName = @"crown";
                break;
            }
            case PGStickerItemsBirthdayHat: {
                sticker.accessibilityText = NSLocalizedString(@"Birthday Hat Sticker", nil);
                sticker.imageName = @"birthdayHat";
                break;
            }
            case PGStickerItemsCatEars: {
                sticker.accessibilityText = NSLocalizedString(@"Cat Ears Sticker", nil);
                sticker.imageName = @"catears";
                break;
            }
            case PGStickerItemsStar: {
                sticker.accessibilityText = NSLocalizedString(@"Star Sticker", nil);
                sticker.imageName = @"starhp";
                break;
            }
            case PGStickerItemsStars: {
                sticker.accessibilityText = NSLocalizedString(@"Stars Sticker", nil);
                sticker.imageName = @"stars";
                break;
            }
            case PGStickerItemsFeather: {
                sticker.accessibilityText = NSLocalizedString(@"Feather Sticker", nil);
                sticker.imageName = @"feather";
                break;
            }
            case PGStickerItemsFeather2: {
                sticker.accessibilityText = NSLocalizedString(@"Feather 2 Sticker", nil);
                sticker.imageName = @"feather2";
                break;
            }
            case PGStickerItemsCupcake: {
                sticker.accessibilityText = NSLocalizedString(@"Cupcake Sticker", nil);
                sticker.imageName = @"cupcake";
                break;
            }
            case PGStickerItemsCat: {
                sticker.accessibilityText = NSLocalizedString(@"Cat Sticker", nil);
                sticker.imageName = @"cat";
                break;
            }
            case PGStickerItemsDiamond: {
                sticker.accessibilityText = NSLocalizedString(@"Diamond Sticker", nil);
                sticker.imageName = @"diamond";
                break;
            }
            case PGStickerItemsOMG: {
                sticker.accessibilityText = NSLocalizedString(@"OMG Sticker", nil);
                sticker.imageName = @"OMG";
                break;
            }
            case PGStickerItemsCatWhiskers: {
                sticker.accessibilityText = NSLocalizedString(@"Cat Whiskers Sticker", nil);
                sticker.imageName = @"catwhiskers";
                break;
            }
            case PGStickerItemsMoon: {
                sticker.accessibilityText = NSLocalizedString(@"Moon Sticker", nil);
                sticker.imageName = @"moon";
                break;
            }
            case PGStickerItemsLeaf3: {
                sticker.accessibilityText = NSLocalizedString(@"Leaf 3 Sticker", nil);
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
            sticker.accessibilityText = NSLocalizedString(@"Chinese Dragon Sticker", nil);
            sticker.imageName = @"dragon2";
            break;
        }
        case PGStickerItemsHatWoman: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Woman Hat Sticker", nil);
            sticker.imageName = @"hat_woman";
            break;
        }
        case PGStickerItemsFirecracker: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Firecracker Sticker", nil);
            sticker.imageName = @"firecracker";
            break;
        }
        case PGStickerItemsHcny: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese HCNY Sticker", nil);
            sticker.imageName = @"hcny";
            break;
        }
        case PGStickerItemsPanda: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Panda Sticker", nil);
            sticker.imageName = @"Panda";
            break;
        }
        case PGStickerItemsHatMan: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Man Hat Sticker", nil);
            sticker.imageName = @"hat_man";
            break;
        }
        case PGStickerItemsMustache1: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Mustache Sticker", nil);
            sticker.imageName = @"mustache_1";
            break;
        }
        case PGStickerItemsHatWoman2: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Woman Hat 2 Sticker", nil);
            sticker.imageName = @"hat_woman2";
            break;
        }
        case PGStickerItemsLionMask: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Lion Mask Sticker", nil);
            sticker.imageName = @"lion_mask";
            break;
        }
        case PGStickerItemsGlassesBlossom: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Glasses Blossom Sticker", nil);
            sticker.imageName = @"glasses_blossom";
            break;
        }
        case PGStickerItemsGlasses2017: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Glasses 2017 Sticker", nil);
            sticker.imageName = @"glasses_2017";
            break;
        }
        case PGStickerItemsFish1: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Fish Sticker", nil);
            sticker.imageName = @"fish_1";
            break;
        }
        case PGStickerItemsLuckyCat: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Lucky Cat Sticker", nil);
            sticker.imageName = @"lucky_cat";
            break;
        }
        case PGStickerItemsLantern: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Lantern Sticker", nil);
            sticker.imageName = @"lantern";
            break;
        }
        case PGStickerItemsFan: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Fan Sticker", nil);
            sticker.imageName = @"fan";
            break;
        }
        case PGStickerItemsDuiLianCouplet: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Dui Lian Couplet Sticker", nil);
            sticker.imageName = @"dui_lian_couplet";
            break;
        }
        case PGStickerItemsFuGoodLuck: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Fu Good Luck Sticker", nil);
            sticker.imageName = @"fu_good_luck";
            break;
        }
        case PGStickerItemsMoney: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Money Sticker", nil);
            sticker.imageName = @"money";
            break;
        }
        case PGStickerItemsYinYang: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Yin Yang Sticker", nil);
            sticker.imageName = @"yinyang";
            break;
        }
        case PGStickerItemsRooster: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Rooster Sticker", nil);
            sticker.imageName = @"rooster";
            break;
        }
        case PGStickerItemsOranges: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Oranges Sticker", nil);
            sticker.imageName = @"oranges";
            break;
        }
        case PGStickerItemsPlumBlossom: {
            sticker.accessibilityText = NSLocalizedString(@"Chinese Plum Blossom Sticker", nil);
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
            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowman Sticker", nil);
            sticker.imageName = @"snowman";
            break;
        }
        case PGStickerItemsRudolphGlasses: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Rudolph Glasses Sticker", nil);
            sticker.imageName = @"glasses_rudolph";
            break;
        }
        case PGStickerItemsChristmasHat: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Elf Hat Sticker", nil);
            sticker.imageName = @"christmas_hat";
            break;
        }
        case PGStickerItemsChristmasStar: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Star Sticker", nil);
            sticker.imageName = @"star0";
            break;
        }
        case PGStickerItemsHanukkahGlasses: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Hanukkah Glasses Sticker", nil);
            sticker.imageName = @"glasses_hanukah";
            break;
        }
        case PGStickerItemsSnowmanHat: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowman Hat Sticker", nil);
            sticker.imageName = @"snowman_hat";
            break;
        }
        case PGStickerItemsPartyHat: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Party Hat Sticker", nil);
            sticker.imageName = @"Party-Hat";
            break;
        }
        case PGStickerItemsTreeGlasses: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Tree Glasses Sticker", nil);
            sticker.imageName = @"glasses_tree";
            break;
        }
        case PGStickerItemsStarGlasses: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Star Glasses Sticker", nil);
            sticker.imageName = @"glasses_star";
            break;
        }
        case PGStickerItemsRudolphAntlers: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Rudolph Antlers Sticker", nil);
            sticker.imageName = @"rudolph_antlers";
            break;
        }
        case PGStickerItemsChristmasCap: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Cap Sticker", nil);
            sticker.imageName = @"cap";
            break;
        }
        case PGStickerItemsSnowmanFace: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowman Face Sticker", nil);
            sticker.imageName = @"snowman_face";
            break;
        }
        case PGStickerItemsChristmasScarf: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Scarf Sticker", nil);
            sticker.imageName = @"scarf";
            break;
        }
        case PGStickerItemsSnowflake: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowflake Sticker", nil);
            sticker.imageName = @"snowflake_2";
            break;
        }
        case PGStickerItemsStringOfLights: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Lights Sticker", nil);
            sticker.imageName = @"StringOLights";
            break;
        }
        case PGStickerItemsChristmasTree: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Tree Sticker", nil);
            sticker.imageName = @"tree";
            break;
        }
        case PGStickerItemsChristmasStocking: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Stocking Sticker", nil);
            sticker.imageName = @"stocking";
            break;
        }
        case PGStickerItemsCandyCane: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Candy Cane Sticker", nil);
            sticker.imageName = @"candy_cane";
            break;
        }
        case PGStickerItemsHolly: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Holly Sticker", nil);
            sticker.imageName = @"holly";
            break;
        }
        case PGStickerItemsMistletoe: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Mistletoe Sticker", nil);
            sticker.imageName = @"mistletoe";
            break;
        }
        case PGStickerItemsChristmasOrnament: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Ornament Sticker", nil);
            sticker.imageName = @"ornament_1";
            break;
        }
        case PGStickerItemsMenorah: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Menorah Sticker", nil);
            sticker.imageName = @"menorah";
            break;
        }
        case PGStickerItemsDreidel: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Dreidel Sticker", nil);
            sticker.imageName = @"dreidle";
            break;
        }
        case PGStickerItemsFireworks: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Fireworks Sticker", nil);
            sticker.imageName = @"fireworks";
            break;
        }
        case PGStickerItemsNewYearHorn: {
            sticker.accessibilityText = NSLocalizedString(@"Holiday Horn Sticker", nil);
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
