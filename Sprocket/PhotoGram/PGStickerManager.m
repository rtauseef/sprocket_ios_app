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

#import "PGStickerManager.h"
#import "NSLocale+Additions.h"

#import "PGCustomStickerManager.h"

@interface PGStickerManager()

@end

@implementation PGStickerManager

+ (PGStickerManager *)sharedInstance
{
    static dispatch_once_t once;
    static PGStickerManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[PGStickerManager alloc] init];
    });
    return sharedInstance;
}

- (NSArray<IMGLYStickerCategory *> *)IMGLYStickersCategories
{
    NSMutableArray<IMGLYSticker *> *fathersDayStickers = [NSMutableArray arrayWithArray:[self fathersDayCategoryStickers]];
    NSInteger fathersDayThumbnailIndex = 0;
    if ([NSLocale isChinese]) {
        //Removing these stickers from chinese because they contain english words.
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        [indexSet addIndex:8];
        [indexSet addIndex:16];
        [indexSet addIndex:21];

        [fathersDayStickers removeObjectsAtIndexes:indexSet];

        fathersDayThumbnailIndex = 3;
    }

    IMGLYStickerCategory *fathersDayCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                  imageURL:fathersDayStickers[fathersDayThumbnailIndex].thumbnailURL
                                                                                  stickers:fathersDayStickers];
    fathersDayCategory.accessibilityLabel = @"Father's Day Category";


    NSMutableArray<IMGLYSticker *> *summerStickers = [NSMutableArray arrayWithArray:[self summerCategoryStickers]];

    IMGLYStickerCategory *summerCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                              imageURL:summerStickers[1].thumbnailURL
                                                                              stickers:summerStickers];
    summerCategory.accessibilityLabel = @"Summer Category";

    NSArray<IMGLYSticker *> *faceStickers = [self faceCategoryStickers];
    IMGLYStickerCategory *faceCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                            imageURL:faceStickers[1].thumbnailURL
                                                                            stickers:faceStickers];
    faceCategory.accessibilityLabel = @"Face Category";


    NSArray<IMGLYSticker *> *decorativeStickers = [self decorativeCategoryStickers];
    IMGLYStickerCategory *decorativeCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                  imageURL:decorativeStickers[1].thumbnailURL
                                                                                  stickers:decorativeStickers];
    decorativeCategory.accessibilityLabel = @"Decorative Category";


    NSArray<IMGLYSticker *> *foodStickers = [self foodCategoryStickers];
    IMGLYStickerCategory *foodCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                            imageURL:foodStickers[1].thumbnailURL
                                                                            stickers:foodStickers];
    foodCategory.accessibilityLabel = @"Food Category";


    NSArray<IMGLYSticker *> *birthdayStickers = [self birthdayCategoryStickers];
    IMGLYStickerCategory *birthdayCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                imageURL:birthdayStickers[3].thumbnailURL
                                                                                stickers:birthdayStickers];
    birthdayCategory.accessibilityLabel = @"Birthday Category";


    NSArray<IMGLYSticker *> *animalStickers = [self animalCategoryStickers];
    IMGLYStickerCategory *animalCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                              imageURL:animalStickers[8].thumbnailURL
                                                                              stickers:animalStickers];
    animalCategory.accessibilityLabel = @"Animal Category";


    NSArray<IMGLYSticker *> *natureStickers = [self natureCategoryStickers];
    IMGLYStickerCategory *natureCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                              imageURL:natureStickers[6].thumbnailURL
                                                                              stickers:natureStickers];
    natureCategory.accessibilityLabel = @"Nature Category";


    NSArray<IMGLYSticker *> *getWellStickers = [self getWellCategoryStickers];
    IMGLYStickerCategory *getWellCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                               imageURL:getWellStickers[1].thumbnailURL
                                                                               stickers:getWellStickers];
    getWellCategory.accessibilityLabel = @"Get Well";

    NSURL *addStickerIcon = [[NSBundle mainBundle] URLForResource:@"customSticker" withExtension:@"png"];
    IMGLYStickerCategory *addCustomCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                 imageURL:addStickerIcon
                                                                                 stickers:@[]];

    addCustomCategory.accessibilityLabel = @"Add Custom Sticker";

    NSMutableArray *categories = [NSMutableArray arrayWithArray:@[addCustomCategory, fathersDayCategory, summerCategory, faceCategory, decorativeCategory, foodCategory, birthdayCategory, animalCategory, natureCategory, getWellCategory]];

    if ([NSLocale isUnitedStates]) {
        NSArray<IMGLYSticker *> *julyStickers = [self July4Stickers];
        IMGLYStickerCategory *julyCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                imageURL:julyStickers[6].thumbnailURL
                                                                                stickers:julyStickers];
        julyCategory.accessibilityLabel = @"July 4th Category";
        
        if ([NSLocale isChinese]) {
            //Removing plane sticker from chinese because it contains english words on it.
            [summerStickers removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:35]];
        }

        [categories insertObject:julyCategory atIndex:2];
    }
    
    NSArray<IMGLYSticker *> *customStickers = [PGCustomStickerManager stickers];
    if (customStickers.count > 0) {
        IMGLYStickerCategory *customCategory       = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                        imageURL:[customStickers firstObject].thumbnailURL
                                                                                        stickers:customStickers];

        customCategory.accessibilityLabel = @"Custom Stickers";
        [categories insertObject:customCategory atIndex:1];
    }

    return categories;
}


#pragma mark - Stickers by category

- (NSArray<IMGLYSticker *> *)fathersDayCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Glasses 1" imageName:@"fd_glasses_1" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Glasses 2" imageName:@"glasses_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mustache" imageName:@"mustache" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Crown 2" imageName:@"crown_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Crown 1" imageName:@"crown_1" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Tie Collar" imageName:@"tie_collar" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mask" imageName:@"mask" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Super Dad" imageName:@"super_dad" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fathers Day 2" imageName:@"fathers_day_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bear" imageName:@"bear" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bacon" imageName:@"bacon" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"BBQ" imageName:@"fd_bbq" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Shoes" imageName:@"shoes" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Coffee 1" imageName:@"coffee_1" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bow Tie" imageName:@"bow_tie" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hat" imageName:@"fd_hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"I Heart Dad 1" imageName:@"i_heart_dad_1" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Banner" imageName:@"fd_heart_banner" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Golf" imageName:@"golf" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Talk Bubble" imageName:@"talk_bubble" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Necktie Fathers Day" imageName:@"necktie_fathersday" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Dad Tattoo" imageName:@"dad_tattoo" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Smoking Pipe" imageName:@"smoking_pipe" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fishing Father Son" imageName:@"fishing_fatherson" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"BBQ Utensils" imageName:@"bbq_utensils" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Golf Set" imageName:@"golf_set" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Strong Arm" imageName:@"strong_arm" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Screwdriver" imageName:@"screwdriver" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Wrench" imageName:@"wrench" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hammer" imageName:@"hammer" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hotrod Car" imageName:@"hotrod_car" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Football Fathers Day" imageName:@"football_fathersday" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)summerCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Flower Glasses" imageName:@"flower_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sunglasses Palmtree" imageName:@"summer_sunglasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sun Hat" imageName:@"sun_hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Popsicle" imageName:@"popsicle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Watermelon" imageName:@"watermelon" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pineapple" imageName:@"Pineapple" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Popsicle Green" imageName:@"popsicle-2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ice Cream Cone" imageName:@"ice_cream_cone" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sun" imageName:@"sun" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mermaid Tail" imageName:@"mermaid_tail" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hibiscus" imageName:@"hibiscus" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sweat" imageName:@"sweat_3" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Palm Tree 2" imageName:@"palm-tree-2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flamingo" imageName:@"flamingo" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Beachball 2" imageName:@"beachball-color" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Radio" imageName:@"radio" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Unicorn" imageName:@"Unicorn" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Floating Flowers 2" imageName:@"floating_flowers_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Visor" imageName:@"visor" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sunglasses Frogskin" imageName:@"sunglasses_frogskin" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Aviator Glasses" imageName:@"aviator_glasses" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Palm Tree" imageName:@"palmtree" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Wave" imageName:@"wave" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sun Face" imageName:@"sun_face" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Beach Umbrella" imageName:@"beach_umbrella" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Beachball" imageName:@"beachball" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Radio Doodle" imageName:@"radio_doodle" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Swim Fins" imageName:@"swim_fins" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Scuba Mask" imageName:@"scuba_mask" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Water Bubbles" imageName:@"water_bubbles" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bike Cruiser" imageName:@"bike_cruiser" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Floating Sloth" imageName:@"floating_sloth" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Kite" imageName:@"kite" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sand Castle" imageName:@"sand_castle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flip Flops 2" imageName:@"flip_flops2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Plane" imageName:@"plane" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fan Summer" imageName:@"fan" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rainbow 2" imageName:@"rainbow_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Dolphin Doodle" imageName:@"dolphin_doodle" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Soda Straw" imageName:@"soda_straw" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mermaid Girl" imageName:@"mermaid_girl" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Surfboard" imageName:@"surfboard" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Unicorn Float" imageName:@"unicorn_float" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mermaid Tail Water" imageName:@"mermaid_tail_water" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"BBQ" imageName:@"bbq" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sundae" imageName:@"sundae" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ice Cream Tub" imageName:@"icecream_tub" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Volleyball" imageName:@"volleyball" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Travel Car Bug" imageName:@"travel_car_bug" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Travel Car Woody" imageName:@"travel_car_woody" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Trailer" imageName:@"trailer" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)faceCategoryStickers
{
    return @[
            [[PGStickerItem alloc] initWithName:@"Aviator Glasses Color" imageName:@"aviator-glasses-color" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Lips" imageName:@"Lips" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat Glasses" imageName:@"catglasses" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses 1" imageName:@"glasses_1" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses" imageName:@"glasses" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Bunny Ears Flowers" imageName:@"bunny_ears_flowers" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat Ears" imageName:@"catears" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Crown" imageName:@"crown" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Sunglasses Frogskin" imageName:@"sunglasses_frogskin" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Aviator Glasses" imageName:@"aviator_glasses" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Rabbit Mask" imageName:@"rabbit-mask" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat Whiskers" imageName:@"catwhiskers" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Birthday Hat" imageName:@"birthdayHat" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Party Hat" imageName:@"Party-Hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Blossom" imageName:@"glasses_blossom" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Sun Hat" imageName:@"sun_hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Derby" imageName:@"Derby" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Red" imageName:@"Glasses-red" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Blinds" imageName:@"Glasses-blinds" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat on Head" imageName:@"cat-on-head" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Panda Mask" imageName:@"panda-mask" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Devil Horns" imageName:@"devilhorns" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Sunglasses" imageName:@"sunglasses" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Mustache Brown" imageName:@"Mustache-brown" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Mustache Dark" imageName:@"Mustache-dark" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Beard" imageName:@"Beard" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"glasses_football" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"bunny_ears_polkadot" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"bunny_ears" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"bunny_face_bow" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"flower_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"medal" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"necktie_graduation" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"nerd_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"pacifier-copy" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
];
}

- (NSArray<IMGLYSticker *> *)decorativeCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Heart Garland" imageName:@"heart-garland" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hearts" imageName:@"v_hearts" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart 2" imageName:@"heart_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hearts Doodle" imageName:@"hearts" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Express" imageName:@"heartExpress" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Stars Bunch" imageName:@"stars_bunch" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Xoxo" imageName:@"xoxo" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Diamond" imageName:@"diamond" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner" imageName:@"banner" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"3D diamond 1" imageName:@"3d-diamond-1" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"3D diamond 2" imageName:@"3d-diamond-2" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather" imageName:@"feather" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Peace" imageName:@"peace" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Thumbs Up" imageName:@"thumbs-up" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fist" imageName:@"fist" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Unicorn" imageName:@"Unicorn" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Wings" imageName:@"heart_wings" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Smiley" imageName:@"smiley" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart" imageName:@"v_heart" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Pixel" imageName:@"heartPixel" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Arrow" imageName:@"heart_arrow" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Arrow" imageName:@"arrow" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather 2" imageName:@"feather2" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Football" imageName:@"Football" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Word Cloud Grumble" imageName:@"word-cloud-grumble" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Skull" imageName:@"skull" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"LOL" imageName:@"LOL" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"OMG" imageName:@"OMG" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Reinvent Memories" imageName:@"ReinventMemories_sticker" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"HP White" imageName:@"HP_white-sticker" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti" imageName:@"confetti" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti Graduation" imageName:@"confetti_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Horn" imageName:@"horn" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ribbon" imageName:@"ribbon" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ribbon Graduation" imageName:@"ribbon_graduation" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             ];
}


- (NSArray<IMGLYSticker *> *)foodCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Frappuccino" imageName:@"Frappuccino" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Doughnut" imageName:@"doughnut" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pizza" imageName:@"pizza" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Taco 2" imageName:@"taco2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Watermelon" imageName:@"watermelon" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pineapple" imageName:@"Pineapple" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bacon n egg" imageName:@"bacon_egg" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Soda Can" imageName:@"Soda_can" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ice Cream Cone" imageName:@"icecreamcone" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Candy" imageName:@"candy" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cupcake" imageName:@"cupcake" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sundae" imageName:@"sundae" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Valentines Cupcake" imageName:@"v_cupcake" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ice Cream Tub" imageName:@"icecream_tub" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Coffee" imageName:@"cat-coffee" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Fries" imageName:@"cat-fries" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ketchup Hot Dog" imageName:@"ketchup-hotdog" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Apple Angry" imageName:@"apple_angry" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Spoon" imageName:@"spoon" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fork" imageName:@"fork" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"BBQ" imageName:@"bbq" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Soda" imageName:@"soda" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Turkey" imageName:@"Turkey-leg" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cocoa" imageName:@"Cocoa" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Oranges" imageName:@"oranges" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pie" imageName:@"Pie" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Carrot" imageName:@"carrot" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Carrot 2" imageName:@"carrot2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Jelly Beans" imageName:@"jelly_beans" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
];
}


- (NSArray<IMGLYSticker *> *)birthdayCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Balloons 2" imageName:@"balloons2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner" imageName:@"banner" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Birthday Hat" imageName:@"birthdayHat" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cake" imageName:@"cake" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Crown" imageName:@"crown" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cupcake" imageName:@"cupcake" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fireworks" imageName:@"fireworks" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Gift" imageName:@"gift" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Gift Dog" imageName:@"gift-dog" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Horn" imageName:@"horn" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Party Hat" imageName:@"Party-Hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Stars" imageName:@"stars" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Balloons" imageName:@"balloons" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Celebrate" imageName:@"cat-celebrate" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti Graduation" imageName:@"confetti_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti" imageName:@"confetti" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Horn" imageName:@"horn" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)animalCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Cat Face" imageName:@"cat_face" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat" imageName:@"cat_body" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Dog" imageName:@"dog" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sloth" imageName:@"sloth" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bird" imageName:@"bird" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fox" imageName:@"Fox" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hedgehog" imageName:@"hedgehog" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Owl" imageName:@"Owl" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Panda" imageName:@"Panda" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Koala" imageName:@"koala" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rabbit" imageName:@"rabbit" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Scary Cat" imageName:@"scarycat" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat on Head" imageName:@"cat-on-head" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Shock" imageName:@"cat-shock" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Grumble" imageName:@"cat_grumble" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Fries" imageName:@"cat-fries" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Spider" imageName:@"spider" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bird Envelope" imageName:@"bird_envelope" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Butterfly" imageName:@"butterfly" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pig" imageName:@"pig" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Birds" imageName:@"birds" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"New Bunny" imageName:@"bunny_new" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Chicks" imageName:@"chicks" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mom Child Cats" imageName:@"Mom_child_cats" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mother Giraffe" imageName:@"mother_giraffe" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mother Turtle" imageName:@"mother_turtle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Owl Scholar" imageName:@"owl_scholar" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Snails" imageName:@"snails" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)natureCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Feather" imageName:@"feather" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hibiscus" imageName:@"hibiscus" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Plum Blossom" imageName:@"plum-blossom" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rosebud" imageName:@"rosebud" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Palm Tree 2" imageName:@"palm-tree-2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rainbow 2" imageName:@"rainbow_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sun" imageName:@"sun" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sun Face" imageName:@"sun_face" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Palm Tree" imageName:@"palmtree" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Wave" imageName:@"wave" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers" imageName:@"Flowers" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Bouquet" imageName:@"heart_bouquet" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Star" imageName:@"starhp" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Stars" imageName:@"stars" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Star Yellow" imageName:@"star_yellow" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Moon" imageName:@"moon" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mushrooms" imageName:@"Mushrooms-b" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cloud Sun" imageName:@"cloud-sun" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cloud Angry" imageName:@"cloud_angry" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cloud Sad" imageName:@"cloud_sad" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather 2" imageName:@"feather2" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers" imageName:@"Flowers2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Leaves" imageName:@"leaves" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Aster Flower" imageName:@"aster_flower" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner 2" imageName:@"banner_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner Copy" imageName:@"banner-copy" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bouquet" imageName:@"bouquet" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather Blue" imageName:@"feather_blue" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Floating Flowers 2" imageName:@"floating_flowers_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flower Leaves Element" imageName:@"flower_leaves_element" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flower Ring" imageName:@"flower_ring" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flower" imageName:@"flower" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Daisies" imageName:@"flowers_daisies" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Left" imageName:@"flowers_left" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Right" imageName:@"flowers_right" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hanging Lillies" imageName:@"hanging_lillies" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Lilly" imageName:@"lilly" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rose" imageName:@"rose" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rosebud Leaves" imageName:@"rosebud_leaves" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Daisies" imageName:@"three_daisies" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Flower Bunch" imageName:@"three_flower_bunch" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Rosebuds" imageName:@"three_rosebuds" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Tulips" imageName:@"tulips" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)getWellCategoryStickers
{
    return @[
              [[PGStickerItem alloc] initWithName:@"Band aid 2" imageName:@"band-aid2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Kleenex" imageName:@"kleenex" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Measles" imageName:@"measles" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Medicine" imageName:@"medicine" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Love Monster" imageName:@"love_monster" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Letter" imageName:@"letter" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Bouquet" imageName:@"bouquet" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Rose" imageName:@"rose" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)July4Stickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"July Uncle Sam Hat" imageName:@"july_uncle_sam_hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Uncle Sam Doodle" imageName:@"july_uncle_sam_hat_doodle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Crown" imageName:@"july_liberty_crown" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Crown Doodle" imageName:@"july_liberty_crown_doodle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Glasses" imageName:@"july_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Patriotic Glasses" imageName:@"july_patriotic_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Flag" imageName:@"july_flag" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Flag Doodle" imageName:@"july_us_flag_doodle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Uncle Sam" imageName:@"july_uncle_sam" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Torch" imageName:@"july_liberty_torch" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Star Glasses" imageName:@"july_glasses_more" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Mustache" imageName:@"july_mustache" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Merica Hat" imageName:@"july_merica_hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Bunting" imageName:@"july_bunting" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Fireworks" imageName:@"july_fireworks" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Stars" imageName:@"july_stars" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July 4th of July" imageName:@"july_4th_of_july" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Popsicle" imageName:@"july_popsicle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Cupcake" imageName:@"july_cupcake" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Heart" imageName:@"july_heart" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Smiley" imageName:@"july_smiley" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Watermelon" imageName:@"july_watermelon" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July BBQ" imageName:@"july_bbqpx" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Soda Can" imageName:@"july_Soda_canpx" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Ice Cream Cone" imageName:@"july_ice_cream_conepx" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Popsicle 2 PX" imageName:@"july_popsicle-2px" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Popsicle PX" imageName:@"july_popsiclepx" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Star Glasses" imageName:@"july_4th_star_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Half Circle Banner" imageName:@"july_us_halfcircle_banner" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Banner Flags" imageName:@"july_us_banner_flags" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Patriotic Pinwheel" imageName:@"july_patriotic_pinwheel" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July 3 Patriotic Stars" imageName:@"july_3_patriotic_stars" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Burst Stars" imageName:@"july_fireworks_burst_stars" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Firework Burst" imageName:@"july_fireworks_burst" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Firework Explode" imageName:@"july_firework_explode" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Firework Rocket" imageName:@"july_firework_rocket" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Doodle" imageName:@"july_4th_of_July_doodle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Happy 4th Of July" imageName:@"july_happy_4th_of_july" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Happy 4th" imageName:@"july_happy_4th" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Merica" imageName:@"july_merica" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Patriotic Popsicle Melt" imageName:@"july_patriotic_popsicle_melt" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Patriotic Popsicle" imageName:@"july_patriotic_popsicle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July BBQ BW" imageName:@"july_bbq" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July BBQ Utensils" imageName:@"july_bbq_utensilspx" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Hamburger" imageName:@"july_hamburger" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Hotdog Doodle" imageName:@"july_hotdog_doodle" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Ketchup Hot Dog" imageName:@"july_ketchup-hotdogpx" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"July Soda Straw" imageName:@"july_soda_straw" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             ];
}

@end
