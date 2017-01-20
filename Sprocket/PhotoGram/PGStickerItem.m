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

static const NSInteger PGStickerItemsCountValentines = 32;
static const NSInteger PGStickerItemsCountSuperBowl = 16;
static const NSInteger PGStickerItemsCountChinese = 22;
static const NSInteger PGStickerItemsCountStandard = 20;

@implementation PGStickerItem

+ (NSInteger)stickerCount
{
    NSInteger numStickers = (PGStickerItemsCountStandard + PGStickerItemsCountValentines + PGStickerItemsCountSuperBowl);
    
    if ([NSLocale isChinese]) {
        numStickers = (PGStickerItemsCountStandard + PGStickerItemsCountValentines + PGStickerItemsCountChinese);
    }
    return numStickers;
}

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index
{
    PGStickerItem *sticker = nil;
    NSInteger stickerOffset = 0;
    
    if ([NSLocale isChinese] && nil == sticker) {
        index -= stickerOffset;
        sticker = [PGStickerItem chineseStickerItemByIndex:index];
        stickerOffset = PGStickerItemsCountChinese;
        
        if (nil == sticker) {
            index -= stickerOffset;
            sticker = [PGStickerItem valentinesStickerItemByIndex:index];
            stickerOffset = PGStickerItemsCountValentines;
        }
    } else {
        sticker = [PGStickerItem valentinesStickerItemByIndex:index];
        stickerOffset = PGStickerItemsCountValentines;
        
        if (nil == sticker) {
            index -= stickerOffset;
            sticker = [PGStickerItem superbowlStickerItemByIndex:index];
            stickerOffset = PGStickerItemsCountSuperBowl;
        }
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

+ (PGStickerItem *)chineseStickerItemByIndex:(NSInteger)index
{
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

+ (PGStickerItem *)valentinesStickerItemByIndex:(NSInteger)index
{
    PGStickerItem *sticker = [[PGStickerItem alloc] init];

    switch (index) {
        case PGStickerItemsValentinesXoxo:
            sticker.name = @"Valentines Xoxo Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Xoxo Sticker", nil);
            sticker.imageName = @"v_xoxo";
            break;
        case PGStickerItemsValentinesHeartFrame:
            sticker.name = @"Valentines Heart Frame Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Frame Sticker", nil);
            sticker.imageName = @"heart_2";
            break;
        case PGStickerItemsValentinesHeartConfetti:
            sticker.name = @"Valentines Heart Confetti Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Confetti Sticker", nil);
            sticker.imageName = @"v_hearts";
            break;
        case PGStickerItemsValentinesConversationHeart:
            sticker.name = @"Valentines Conversation Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Conversation Heart Sticker", nil);
            sticker.imageName = @"conversation_heart";
            break;
        case PGStickerItemsValentinesFlyingHeart:
            sticker.name = @"Valentines Flying Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Flying Heart Sticker", nil);
            sticker.imageName = @"heart_wings";
            break;
        case PGStickerItemsValentinesDeliveryBird:
            sticker.name = @"Valentines Delivery Bird Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Delivery Bird Sticker", nil);
            sticker.imageName = @"bird";
            break;
        case PGStickerItemsValentinesButterFly:
            sticker.name = @"Valentines Butterfly Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Butterfly Sticker", nil);
            sticker.imageName = @"butterfly";
            break;
        case PGStickerItemsValentinesHeartMonster:
            sticker.name = @"Valentines Heart Monster Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Monster Sticker", nil);
            sticker.imageName = @"monster_2";
            break;
        case PGStickerItemsValentinesRoseBud:
            sticker.name = @"Valentines Rosebud Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Rosebud Sticker", nil);
            sticker.imageName = @"rosebud";
            break;
        case PGStickerItemsValentinesHeartBouquet:
            sticker.name = @"Valentines Heart Bouquet Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Bouquet Sticker", nil);
            sticker.imageName = @"heart_bouquet";
            break;
        case PGStickerItemsValentinesHeartGarland:
            sticker.name = @"Valentines Heart Garland Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Garland Sticker", nil);
            sticker.imageName = @"heart-garland";
            break;
        case PGStickerItemsValentinesPig:
            sticker.name = @"Valentines Pig Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Pig Sticker", nil);
            sticker.imageName = @"pig";
            break;
        case PGStickerItemsValentinesHeartAntennae:
            sticker.name = @"Valentines Heart Antennae Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Antennae Sticker", nil);
            sticker.imageName = @"headband";
            break;
        case PGStickerItemsValentinesHeartGlasses:
            sticker.name = @"Valentines Heart Glasses Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Glasses Sticker", nil);
            sticker.imageName = @"glasses_1";
            break;
        case PGStickerItemsValentinesHat:
            sticker.name = @"Valentines Hat Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Hat Sticker", nil);
            sticker.imageName = @"hat";
            break;
        case PGStickerItemsValentinesHeartBow:
            sticker.name = @"Valentines Heart Bow Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Bow Sticker", nil);
            sticker.imageName = @"bow2";
            break;
        case PGStickerItemsValentinesHeartBalloons:
            sticker.name = @"Valentines Heart Balloons Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Balloons Sticker", nil);
            sticker.imageName = @"balloons";
            break;
        case PGStickerItemsValentinesHeartThought:
            sticker.name = @"Valentines Heart Thought Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Thought Sticker", nil);
            sticker.imageName = @"thought_bubble";
            break;
        case PGStickerItemsValentinesLoveLetter:
            sticker.name = @"Valentines Love Letter Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Love Letter Sticker", nil);
            sticker.imageName = @"letter";
            break;
        case PGStickerItemsValentinesDancingHearts:
            sticker.name = @"Valentines Dancing Hearts Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Dancing Hearts Sticker", nil);
            sticker.imageName = @"holding_hands";
            break;
        case PGStickerItemsValentinesLoveCreature:
            sticker.name = @"Valentines Love Creature Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Love Creature Sticker", nil);
            sticker.imageName = @"love_monster";
            break;
        case PGStickerItemsValentinesHeartArrow:
            sticker.name = @"Valentines Heart Arrow Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Arrow Sticker", nil);
            sticker.imageName = @"heart_arrow";
            break;
        case PGStickerItemsValentinesHeartEmoji:
            sticker.name = @"Valentines Heart Emoji Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Emoji Sticker", nil);
            sticker.imageName = @"smiley";
            break;
        case PGStickerItemsValentinesHeartBanner:
            sticker.name = @"Valentines Heart Banner Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Banner Sticker", nil);
            sticker.imageName = @"heart_banner";
            break;
        case PGStickerItemsValentinesLockAndKey:
            sticker.name = @"Valentines Lock And Key Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Lock And Key Sticker", nil);
            sticker.imageName = @"lock";
            break;
        case PGStickerItemsValentinesCupcake:
            sticker.name = @"Valentines Cupcake Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Cupcake Sticker", nil);
            sticker.imageName = @"v_cupcake";
            break;
        case PGStickerItemsValentinesCat:
            sticker.name = @"Valentines Cat Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Cat Sticker", nil);
            sticker.imageName = @"v_cat";
            break;
        case PGStickerItemsValentinesBrokenHeart:
            sticker.name = @"Valentines Broken Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Broken Heart Sticker", nil);
            sticker.imageName = @"v_heart";
            break;
        case PGStickerItemsValentinesTargetHeart:
            sticker.name = @"Valentines Target Heart Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Target Heart Sticker", nil);
            sticker.imageName = @"target";
            break;
        case PGStickerItemsValentinesHeartGlassesTwo:
            sticker.name = @"Valentines Heart Glasses Two Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Glasses Two Sticker", nil);
            sticker.imageName = @"glasses";
            break;
        case PGStickerItemsValentinesHeartTiara:
            sticker.name = @"Valentines Heart Tiara Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Heart Tiara Sticker", nil);
            sticker.imageName = @"tiara";
            break;
        case PGStickerItemsValentinesFlowerCrown:
            sticker.name = @"Valentines Flower Crown Sticker";
            sticker.accessibilityText = NSLocalizedString(@"Valentines Flower Crown Sticker", nil);
            sticker.imageName = @"heart_crown";
            break;
        default:
            sticker = nil;
            break;
    }
    
    return sticker;
}

+ (PGStickerItem *)superbowlStickerItemByIndex:(NSInteger)index
{
    PGStickerItem *sticker = [[PGStickerItem alloc] init];
    
    switch (index) {
        case PGStickerItemsSuperBowlGlasses:
            sticker.name = @"SuperBowl Glasses Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Glasses Sticker", nil);
            sticker.imageName = @"sb_glasses";
            break;
        case PGStickerItemsSuperBowlGlassesTwo:
            sticker.name = @"SuperBowl Glasses Two Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Glasses Two Sticker", nil);
            sticker.imageName = @"glasses_2";
            break;
        case PGStickerItemsSuperBowlEyeBlack:
            sticker.name = @"SuperBowl Eye Black Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Eye Black Sticker", nil);
            sticker.imageName = @"eye_black";
            break;
        case PGStickerItemsSuperBowlFoamFinger:
            sticker.name = @"SuperBowl Foam Finger Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Foam Finger Sticker", nil);
            sticker.imageName = @"foam_finger";
            break;
        case PGStickerItemsSuperBowlHeartFootball:
            sticker.name = @"SuperBowl Heart Football Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Heart Football Sticker", nil);
            sticker.imageName = @"heart_football3";
            break;
        case PGStickerItemsSuperBowlBanner:
            sticker.name = @"SuperBowl Banner Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Banner Sticker", nil);
            sticker.imageName = @"banner";
            break;
        case PGStickerItemsSuperBowlFlag:
            sticker.name = @"SuperBowl Flag Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Flag Sticker", nil);
            sticker.imageName = @"flag";
            break;
        case PGStickerItemsSuperBowlHeartFootballTwo:
            sticker.name = @"SuperBowl Heart Football Two Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Heart Football Two Sticker", nil);
            sticker.imageName = @"heart_football";
            break;
        case PGStickerItemsSuperBowlStarsNBalls:
            sticker.name = @"SuperBowl Stars n Balls Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Stars n Balls Sticker", nil);
            sticker.imageName = @"stars_n_balls";
            break;
        case PGStickerItemsSuperBowlGameTime:
            sticker.name = @"SuperBowl Game Time Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Game Time Sticker", nil);
            sticker.imageName = @"#_game_time";
            break;
        case PGStickerItemsSuperBowlFootballFlames:
            sticker.name = @"SuperBowl Football Flames Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Football Flames Sticker", nil);
            sticker.imageName = @"football_flames";
            break;
        case PGStickerItemsSuperBowlLove:
            sticker.name = @"SuperBowl Love Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Love Sticker", nil);
            sticker.imageName = @"love";
            break;
        case PGStickerItemsSuperBowlIHeartFootball:
            sticker.name = @"SuperBowl I Heart Football Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl I Heart Football Sticker", nil);
            sticker.imageName = @"i_heart_football_2";
            break;
        case PGStickerItemsSuperBowlOwl:
            sticker.name = @"SuperBowl Owl Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Owl Sticker", nil);
            sticker.imageName = @"owl";
            break;
        case PGStickerItemsSuperBowlGoalPost:
            sticker.name = @"SuperBowl Goal Post Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Goal Post Sticker", nil);
            sticker.imageName = @"goal_post_2";
            break;
        case PGStickerItemsSuperBowlHelmet:
            sticker.name = @"SuperBowl Helmet Sticker";
            sticker.accessibilityText = NSLocalizedString(@"SuperBowl Helmet Sticker", nil);
            sticker.imageName = @"helmet";
            break;
        default:
            sticker = nil;
            break;
    }
    
    return sticker;
}


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

- (UIImage *)thumbnailImage
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_TN", self.imageName]];
}

- (UIImage *)stickerImage
{
    return [UIImage imageNamed:self.imageName];
}

@end
