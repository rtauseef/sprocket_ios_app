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

//static const NSInteger PGStickerItemsCountHoliday = 25;
static const NSInteger PGStickerItemsCountValentines = 32;
static const NSInteger PGStickerItemsCountSuperBowl = 16;
static const NSInteger PGStickerItemsCountChinese = 22;
static const NSInteger PGStickerItemsCountStandard = 20;

@implementation PGStickerItem

+ (NSInteger)stickerCount
{
    NSInteger numStickers = (PGStickerItemsCountStandard + PGStickerItemsCountValentines + PGStickerItemsCountSuperBowl);
    
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
        sticker = [PGStickerItem valentinesStickerItemByIndex:index];
        stickerOffset = PGStickerItemsCountValentines + PGStickerItemsCountSuperBowl;
    }

    if (nil == sticker) {
        index -= stickerOffset;
        sticker = [[PGStickerItem alloc] init];
        
        switch (index) {
            case PGStickerItemsCatGlasses: {
                sticker.name = @"Cat Glasses Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Cat Glasses Sticker", nil);
                sticker.imageName = @"catglasses";
                break;
            }
            case PGStickerItemsSunglasses: {
                sticker.name = @"Sunglasses Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Sunglasses Sticker", nil);
                sticker.imageName = @"sunglasses";
                break;
            }
            case PGStickerItemsHearts: {
                sticker.name = @"Hearts Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Hearts Sticker", nil);
                sticker.imageName = @"hearts";
                break;
            }
            case PGStickerItemsXoxo: {
                sticker.name = @"XOXO Sticker";
                sticker.accessibilityText = NSLocalizedString(@"XOXO Sticker", nil);
                sticker.imageName = @"xoxo";
                break;
            }
            case PGStickerItemsHeartExpress: {
                sticker.name = @"Heart Express Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Heart Express Sticker", nil);
                sticker.imageName = @"heartExpress";
                break;
            }
            case PGStickerItemsArrow: {
                sticker.name = @"Arrow Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Arrow Sticker", nil);
                sticker.imageName = @"arrow";
                break;
            }
            case PGStickerItemsCrown: {
                sticker.name = @"Crown Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Crown Sticker", nil);
                sticker.imageName = @"crown";
                break;
            }
            case PGStickerItemsBirthdayHat: {
                sticker.name = @"Birthday Hat Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Birthday Hat Sticker", nil);
                sticker.imageName = @"birthdayHat";
                break;
            }
            case PGStickerItemsCatEars: {
                sticker.name = @"Cat Ears Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Cat Ears Sticker", nil);
                sticker.imageName = @"catears";
                break;
            }
            case PGStickerItemsStar: {
                sticker.name = @"Star Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Star Sticker", nil);
                sticker.imageName = @"starhp";
                break;
            }
            case PGStickerItemsStars: {
                sticker.name = @"Stars Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Stars Sticker", nil);
                sticker.imageName = @"stars";
                break;
            }
            case PGStickerItemsFeather: {
                sticker.name = @"Feather Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Feather Sticker", nil);
                sticker.imageName = @"feather";
                break;
            }
            case PGStickerItemsFeather2: {
                sticker.name = @"Feather 2 Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Feather 2 Sticker", nil);
                sticker.imageName = @"feather2";
                break;
            }
            case PGStickerItemsCupcake: {
                sticker.name = @"Cupcake Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Cupcake Sticker", nil);
                sticker.imageName = @"cupcake";
                break;
            }
            case PGStickerItemsCat: {
                sticker.name = @"Cat Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Cat Sticker", nil);
                sticker.imageName = @"cat";
                break;
            }
            case PGStickerItemsDiamond: {
                sticker.name = @"Diamond Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Diamond Sticker", nil);
                sticker.imageName = @"diamond";
                break;
            }
            case PGStickerItemsOMG: {
                sticker.name = @"OMG Sticker";
                sticker.accessibilityText = NSLocalizedString(@"OMG Sticker", nil);
                sticker.imageName = @"OMG";
                break;
            }
            case PGStickerItemsCatWhiskers: {
                sticker.name = @"Cat Whiskers Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Cat Whiskers Sticker", nil);
                sticker.imageName = @"catwhiskers";
                break;
            }
            case PGStickerItemsMoon: {
                sticker.name = @"Moon Sticker";
                sticker.accessibilityText = NSLocalizedString(@"Moon Sticker", nil);
                sticker.imageName = @"moon";
                break;
            }
            case PGStickerItemsLeaf3: {
                sticker.name = @"Leaf 3 Sticker";
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
            sticker.name = @"Chinese Dragon Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Dragon Sticker", nil);
            sticker.imageName = @"dragon2";
            break;
        }
        case PGStickerItemsHatWoman: {
            sticker.name = @"Chinese Woman Hat Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Woman Hat Sticker", nil);
            sticker.imageName = @"hat_woman";
            break;
        }
        case PGStickerItemsFirecracker: {
            sticker.name = @"Chinese Firecracker Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Firecracker Sticker", nil);
            sticker.imageName = @"firecracker";
            break;
        }
        case PGStickerItemsHcny: {
            sticker.name = @"Chinese HCNY Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese HCNY Sticker", nil);
            sticker.imageName = @"hcny";
            break;
        }
        case PGStickerItemsPanda: {
            sticker.name = @"Chinese Panda Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Panda Sticker", nil);
            sticker.imageName = @"Panda";
            break;
        }
        case PGStickerItemsHatMan: {
            sticker.name = @"Chinese Man Hat Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Man Hat Sticker", nil);
            sticker.imageName = @"hat_man";
            break;
        }
        case PGStickerItemsMustache1: {
            sticker.name = @"Chinese Mustache Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Mustache Sticker", nil);
            sticker.imageName = @"mustache_1";
            break;
        }
        case PGStickerItemsHatWoman2: {
            sticker.name = @"Chinese Woman Hat 2 Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Woman Hat 2 Sticker", nil);
            sticker.imageName = @"hat_woman2";
            break;
        }
        case PGStickerItemsLionMask: {
            sticker.name = @"Chinese Lion Mask Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Lion Mask Sticker", nil);
            sticker.imageName = @"lion_mask";
            break;
        }
        case PGStickerItemsGlassesBlossom: {
            sticker.name = @"Chinese Glasses Blossom Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Glasses Blossom Sticker", nil);
            sticker.imageName = @"glasses_blossom";
            break;
        }
        case PGStickerItemsGlasses2017: {
            sticker.name = @"Chinese Glasses 2017 Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Glasses 2017 Sticker", nil);
            sticker.imageName = @"glasses_2017";
            break;
        }
        case PGStickerItemsFish1: {
            sticker.name = @"Chinese Fish Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Fish Sticker", nil);
            sticker.imageName = @"fish_1";
            break;
        }
        case PGStickerItemsLuckyCat: {
            sticker.name = @"Chinese Lucky Cat Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Lucky Cat Sticker", nil);
            sticker.imageName = @"lucky_cat";
            break;
        }
        case PGStickerItemsLantern: {
            sticker.name = @"Chinese Lantern Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Lantern Sticker", nil);
            sticker.imageName = @"lantern";
            break;
        }
        case PGStickerItemsFan: {
            sticker.name = @"Chinese Fan Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Fan Sticker", nil);
            sticker.imageName = @"fan";
            break;
        }
        case PGStickerItemsDuiLianCouplet: {
            sticker.name = @"Chinese Dui Lian Couplet Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Dui Lian Couplet Sticker", nil);
            sticker.imageName = @"dui_lian_couplet";
            break;
        }
        case PGStickerItemsFuGoodLuck: {
            sticker.name = @"Chinese Fu Good Luck Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Fu Good Luck Sticker", nil);
            sticker.imageName = @"fu_good_luck";
            break;
        }
        case PGStickerItemsMoney: {
            sticker.name = @"Chinese Money Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Money Sticker", nil);
            sticker.imageName = @"money";
            break;
        }
        case PGStickerItemsYinYang: {
            sticker.name = @"Chinese Yin Yang Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Yin Yang Sticker", nil);
            sticker.imageName = @"yinyang";
            break;
        }
        case PGStickerItemsRooster: {
            sticker.name = @"Chinese Rooster Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Rooster Sticker", nil);
            sticker.imageName = @"rooster";
            break;
        }
        case PGStickerItemsOranges: {
            sticker.name = @"Chinese Oranges Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Chinese Oranges Sticker", nil);
            sticker.imageName = @"oranges";
            break;
        }
        case PGStickerItemsPlumBlossom: {
            sticker.name = @"Chinese Plum Blossom Sticker";
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

+ (PGStickerItem *)valentinesStickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = [[PGStickerItem alloc] init];

    switch (index) {
        case PGStickerItemsValentinesXoxo:
            sticker.name = @"Valentines Xoxo Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Xoxo Sticker", nil);
            sticker.imageName = @"xoxo";
            break;
        case PGStickerItemsValentinesHeartFrame:
            sticker.name = @"Heart Frame Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Frame Sticker", nil);
            sticker.imageName = @"heart_2";
            break;
        case PGStickerItemsValentinesHeartConfetti:
            sticker.name = @"Heart Confetti Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Confetti Sticker", nil);
            sticker.imageName = @"hearts";
            break;
        case PGStickerItemsValentinesConversationHeart:
            sticker.name = @"Conversation Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Conversation Heart Sticker", nil);
            sticker.imageName = @"conversation_heart";
            break;
        case PGStickerItemsValentinesFlyingHeart:
            sticker.name = @"Flying Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Flying Heart Sticker", nil);
            sticker.imageName = @"heart_wings";
            break;
        case PGStickerItemsValentinesDeliveryBird:
            sticker.name = @"Delivery Bird Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Delivery Bird Sticker", nil);
            sticker.imageName = @"bird";
            break;
        case PGStickerItemsValentinesButterFly:
            sticker.name = @"Butterfly Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Butterfly Sticker", nil);
            sticker.imageName = @"butterfly";
            break;
        case PGStickerItemsValentinesHeartMonster:
            sticker.name = @"Heart Monster Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Monster Sticker", nil);
            sticker.imageName = @"monster_2";
            break;
        case PGStickerItemsValentinesRoseBud:
            sticker.name = @"Rosebud Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Rosebud Sticker", nil);
            sticker.imageName = @"rosebud";
            break;
        case PGStickerItemsValentinesHeartBouquet:
            sticker.name = @"Heart Bouquet Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Bouquet Sticker", nil);
            sticker.imageName = @"heart_bouquet";
            break;
        case PGStickerItemsValentinesHeartGarland:
            sticker.name = @"Heart Garland Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Garland Sticker", nil);
            sticker.imageName = @"heart-garland";
            break;
        case PGStickerItemsValentinesPig:
            sticker.name = @"Pig Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Pig Sticker", nil);
            sticker.imageName = @"pig";
            break;
        case PGStickerItemsValentinesHeartAntennae:
            sticker.name = @"Heart Antennae Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Antennae Sticker", nil);
            sticker.imageName = @"headband";
            break;
        case PGStickerItemsValentinesHeartGlasses:
            sticker.name = @"Heart Glasses Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Glasses Sticker", nil);
            sticker.imageName = @"glasses_1";
            break;
        case PGStickerItemsValentinesHat:
            sticker.name = @"Hat Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Hat Sticker", nil);
            sticker.imageName = @"hat";
            break;
        case PGStickerItemsValentinesHeartBow:
            sticker.name = @"Heart Bow Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Bow Sticker", nil);
            sticker.imageName = @"bow2";
            break;
        case PGStickerItemsValentinesHeartBalloons:
            sticker.name = @"Heart Balloons Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Balloons Sticker", nil);
            sticker.imageName = @"balloons";
            break;
        case PGStickerItemsValentinesHeartThought:
            sticker.name = @"Heart Thought Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Thought Sticker", nil);
            sticker.imageName = @"thought_bubble";
            break;
        case PGStickerItemsValentinesLoveLetter:
            sticker.name = @"Love Letter Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Love Letter Sticker", nil);
            sticker.imageName = @"letter";
            break;
        case PGStickerItemsValentinesDancingHearts:
            sticker.name = @"Dancing Hearts Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Dancing Hearts Sticker", nil);
            sticker.imageName = @"holding_hands";
            break;
        case PGStickerItemsValentinesLoveCreature:
            sticker.name = @"Love Creature Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Love Creature Sticker", nil);
            sticker.imageName = @"love_monster";
            break;
        case PGStickerItemsValentinesHeartArrow:
            sticker.name = @"Heart Arrow Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Arrow Sticker", nil);
            sticker.imageName = @"heart_arrow";
            break;
        case PGStickerItemsValentinesHeartEmoji:
            sticker.name = @"Heart Emoji Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Emoji Sticker", nil);
            sticker.imageName = @"smiley";
            break;
        case PGStickerItemsValentinesHeartBanner:
            sticker.name = @"Heart Banner Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Banner Sticker", nil);
            sticker.imageName = @"heart_banner";
            break;
        case PGStickerItemsValentinesLockAndKey:
            sticker.name = @"Lock And Key Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Lock And Key Sticker", nil);
            sticker.imageName = @"lock";
            break;
        case PGStickerItemsValentinesCupcake:
            sticker.name = @"Cupcake Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Cupcake Sticker", nil);
            sticker.imageName = @"cupcake";
            break;
        case PGStickerItemsValentinesCat:
            sticker.name = @"Cat Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Cat Sticker", nil);
            sticker.imageName = @"cat";
            break;
        case PGStickerItemsValentinesBrokenHeart:
            sticker.name = @"Broken Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Broken Heart Sticker", nil);
            sticker.imageName = @"heart";
            break;
        case PGStickerItemsValentinesTargetHeart:
            sticker.name = @"Target Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Target Heart Sticker", nil);
            sticker.imageName = @"target";
            break;
        case PGStickerItemsValentinesHeartGlassesTwo:
            sticker.name = @"Heart Glasses Two Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Glasses Two Sticker", nil);
            sticker.imageName = @"glasses";
            break;
        case PGStickerItemsValentinesHeartTiara:
            sticker.name = @"Heart Tiara Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Heart Tiara Sticker", nil);
            sticker.imageName = @"tiara";
            break;
        case PGStickerItemsValentinesFlowerCrown:
            sticker.name = @"Flower Crown Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Flower Crown Sticker", nil);
            sticker.imageName = @"heart_crown";
            break;
        default:
            sticker = nil;
            break;
    }
    
    return sticker;
}

//+ (PGStickerItem *)holidayStickerItemByIndex:(NSInteger)index {
//    PGStickerItem *sticker = [[PGStickerItem alloc] init];
//    
//    switch (index) {
//        case PGStickerItemsSnowman: {
//            sticker.name = @"Holiday Snowman Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowman Sticker", nil);
//            sticker.imageName = @"snowman";
//            break;
//        }
//        case PGStickerItemsRudolphGlasses: {
//            sticker.name = @"Holiday Rudolph Glasses Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Rudolph Glasses Sticker", nil);
//            sticker.imageName = @"glasses_rudolph";
//            break;
//        }
//        case PGStickerItemsChristmasHat: {
//            sticker.name = @"Holiday Elf Hat Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Elf Hat Sticker", nil);
//            sticker.imageName = @"christmas_hat";
//            break;
//        }
//        case PGStickerItemsChristmasStar: {
//            sticker.name = @"Holiday Star Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Star Sticker", nil);
//            sticker.imageName = @"star0";
//            break;
//        }
//        case PGStickerItemsHanukkahGlasses: {
//            sticker.name = @"Holiday Hanukkah Glasses Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Hanukkah Glasses Sticker", nil);
//            sticker.imageName = @"glasses_hanukah";
//            break;
//        }
//        case PGStickerItemsSnowmanHat: {
//            sticker.name = @"Holiday Snowman Hat Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowman Hat Sticker", nil);
//            sticker.imageName = @"snowman_hat";
//            break;
//        }
//        case PGStickerItemsPartyHat: {
//            sticker.name = @"Holiday Party Hat Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Party Hat Sticker", nil);
//            sticker.imageName = @"Party-Hat";
//            break;
//        }
//        case PGStickerItemsTreeGlasses: {
//            sticker.name = @"Holiday Tree Glasses Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Tree Glasses Sticker", nil);
//            sticker.imageName = @"glasses_tree";
//            break;
//        }
//        case PGStickerItemsStarGlasses: {
//            sticker.name = @"Holiday Star Glasses Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Star Glasses Sticker", nil);
//            sticker.imageName = @"glasses_star";
//            break;
//        }
//        case PGStickerItemsRudolphAntlers: {
//            sticker.name = @"Holiday Rudolph Antlers Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Rudolph Antlers Sticker", nil);
//            sticker.imageName = @"rudolph_antlers";
//            break;
//        }
//        case PGStickerItemsChristmasCap: {
//            sticker.name = @"Holiday Christmas Cap Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Cap Sticker", nil);
//            sticker.imageName = @"cap";
//            break;
//        }
//        case PGStickerItemsSnowmanFace: {
//            sticker.name = @"Holiday Snowman Face Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowman Face Sticker", nil);
//            sticker.imageName = @"snowman_face";
//            break;
//        }
//        case PGStickerItemsChristmasScarf: {
//            sticker.name = @"Holiday Christmas Scarf Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Scarf Sticker", nil);
//            sticker.imageName = @"scarf";
//            break;
//        }
//        case PGStickerItemsSnowflake: {
//            sticker.name = @"Holiday Snowflake Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Snowflake Sticker", nil);
//            sticker.imageName = @"snowflake_2";
//            break;
//        }
//        case PGStickerItemsStringOfLights: {
//            sticker.name = @"Holiday Lights Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Lights Sticker", nil);
//            sticker.imageName = @"StringOLights";
//            break;
//        }
//        case PGStickerItemsChristmasTree: {
//            sticker.name = @"Holiday Christmas Tree Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Tree Sticker", nil);
//            sticker.imageName = @"tree";
//            break;
//        }
//        case PGStickerItemsChristmasStocking: {
//            sticker.name = @"Holiday Christmas Stocking Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Stocking Sticker", nil);
//            sticker.imageName = @"stocking";
//            break;
//        }
//        case PGStickerItemsCandyCane: {
//            sticker.name = @"Holiday Candy Cane Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Candy Cane Sticker", nil);
//            sticker.imageName = @"candy_cane";
//            break;
//        }
//        case PGStickerItemsHolly: {
//            sticker.name = @"Holiday Holly Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Holly Sticker", nil);
//            sticker.imageName = @"holly";
//            break;
//        }
//        case PGStickerItemsMistletoe: {
//            sticker.name = @"Holiday Mistletoe Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Mistletoe Sticker", nil);
//            sticker.imageName = @"mistletoe";
//            break;
//        }
//        case PGStickerItemsChristmasOrnament: {
//            sticker.name = @"Holiday Christmas Ornament Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Christmas Ornament Sticker", nil);
//            sticker.imageName = @"ornament_1";
//            break;
//        }
//        case PGStickerItemsMenorah: {
//            sticker.name = @"Holiday Menorah Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Menorah Sticker", nil);
//            sticker.imageName = @"menorah";
//            break;
//        }
//        case PGStickerItemsDreidel: {
//            sticker.name = @"Holiday Dreidel Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Dreidel Sticker", nil);
//            sticker.imageName = @"dreidle";
//            break;
//        }
//        case PGStickerItemsFireworks: {
//            sticker.name = @"Holiday Fireworks Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Fireworks Sticker", nil);
//            sticker.imageName = @"fireworks";
//            break;
//        }
//        case PGStickerItemsNewYearHorn: {
//            sticker.name = @"Holiday Horn Sticker";
//            sticker.accessibilityText = NSLocalizedString(@"Holiday Horn Sticker", nil);
//            sticker.imageName = @"horn";
//            break;
//        }
//        default:
//            sticker = nil;
//            break;
//    };
//
//    return sticker;
//}

+ (PGStickerItem *)stickerByAccessibilityText:(NSString *)accessibilityText
{
    PGStickerItem *sticker = nil;
    NSInteger stickerCount = [PGStickerItem stickerCount];
    
    for (NSInteger i=0; i<stickerCount; ++i) {
        PGStickerItem *stickerItem = [PGStickerItem stickerItemByIndex:i];
        if ([accessibilityText isEqualToString:stickerItem.accessibilityText]) {
            sticker = stickerItem;
            break;
        }
    }
    
    return sticker;
}

- (UIImage *)thumbnailImage {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_TN", self.imageName]];
}

- (UIImage *)stickerImage {
    return [UIImage imageNamed:self.imageName];
}

@end
