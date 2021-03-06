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
#import "PGCloudAssetClient.h"
#import "PGCloudAssetStorage.h"
#import "PGCustomStickerManager.h"
#import "PGFeatureFlag.h"

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
    NSMutableArray *categories = [[NSMutableArray alloc] init];

    // User Generated Stickers

    NSURL *addStickerIcon = [[NSBundle mainBundle] URLForResource:@"customSticker" withExtension:@"png"];
    IMGLYStickerCategory *addCustomCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                 imageURL:addStickerIcon
                                                                                 stickers:@[]];

    addCustomCategory.accessibilityLabel = @"Add Custom Sticker";

    [categories addObject:addCustomCategory];

    NSArray<IMGLYSticker *> *customStickers = [PGCustomStickerManager stickers];
    if (customStickers.count > 0) {
        IMGLYStickerCategory *customCategory       = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                        imageURL:[customStickers firstObject].thumbnailURL
                                                                                        stickers:customStickers];

        customCategory.accessibilityLabel = @"Custom Stickers";
        [categories addObject:customCategory];
    }


    // Cloud Asset Stickers

    if ([PGFeatureFlag isCloudAssetsEnabled]) {
        PGCloudAssetClient *cac = [[PGCloudAssetClient alloc] init];
        NSArray<PGCloudAssetCategory *> *catalog = [cac currentStickersCatalog];
        PGCloudAssetStorage *storage = [[PGCloudAssetStorage alloc] init];

        for (PGCloudAssetCategory *category in catalog) {
            NSMutableArray<IMGLYSticker *> *imglyStickers = [[NSMutableArray alloc] init];

            for (PGCloudAssetImage *sticker in category.imageAssets) {
                NSURL *localURL = [NSURL fileURLWithPath:[storage localUrlForAsset:sticker]];
                NSURL *localThumbnailURL = [NSURL fileURLWithPath:[storage localThumbnailUrlForAsset:sticker]];

                IMGLYSticker *imglySticker = [[IMGLYSticker alloc] initWithImageURL:localURL
                                                                       thumbnailURL:localThumbnailURL
                                                                           tintMode:IMGLYStickerTintModeNone];
                imglySticker.accessibilityLabel = [NSString stringWithFormat:@"%@-%li", sticker.name, sticker.version];

                [imglyStickers addObject:imglySticker];
            }

            IMGLYStickerCategory *imglyCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:[NSURL URLWithString:category.thumbnailURL]
                                                                                     stickers:imglyStickers];
            imglyCategory.accessibilityLabel = category.analyticsId;
            
            [categories addObject:imglyCategory];
        }
    }

    
    // Default Stickers

    NSMutableArray<IMGLYSticker *> *fathersDayStickers = [NSMutableArray arrayWithArray:[self fathersDayCategoryStickers]];
    NSInteger fathersDayThumbnailIndex = 1;

    IMGLYStickerCategory *fathersDayCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                  imageURL:fathersDayStickers[fathersDayThumbnailIndex].thumbnailURL
                                                                                  stickers:fathersDayStickers];
    fathersDayCategory.accessibilityLabel = @"Father's Day Category";


    NSMutableArray<IMGLYSticker *> *summerStickers = [NSMutableArray arrayWithArray:[self summerCategoryStickers]];
    if ([NSLocale isChinese]) {
        //Removing plane sticker from chinese because it contains english words on it.
        [summerStickers removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:35]];
    }

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


    NSArray<IMGLYSticker *> *disneyStickers = [self disneyCategoryStickers];
    IMGLYStickerCategory *disneyCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                               imageURL:disneyStickers[1].thumbnailURL
                                                                               stickers:disneyStickers];
    disneyCategory.accessibilityLabel = @"Disney";

    [categories addObjectsFromArray:@[summerCategory, fathersDayCategory, faceCategory, decorativeCategory, foodCategory, birthdayCategory, animalCategory, natureCategory, getWellCategory, disneyCategory]];

    return categories;
}


#pragma mark - Stickers by category

- (NSArray<IMGLYSticker *> *)fathersDayCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Glasses 2" imageName:@"glasses_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mustache" imageName:@"mustache" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Crown 2" imageName:@"crown_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Crown 1" imageName:@"crown_1" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Tie Collar" imageName:@"tie_collar" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mask" imageName:@"mask" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Super Dad" imageName:@"super_dad" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bear" imageName:@"bear" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bacon" imageName:@"bacon" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"BBQ" imageName:@"fd_bbq" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Shoes" imageName:@"shoes" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Coffee 1" imageName:@"coffee_1" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bow Tie" imageName:@"bow_tie" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hat" imageName:@"fd_hat" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Banner" imageName:@"fd_heart_banner" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Golf" imageName:@"golf" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Talk Bubble" imageName:@"talk_bubble" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Necktie Fathers Day" imageName:@"necktie_fathersday" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
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
            [[PGStickerItem alloc] initWithName:@"Bunny Ears Polkadot" imageName:@"bunny_ears_polkadot" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Bunny Ears" imageName:@"bunny_ears" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Bunny Face Bow" imageName:@"bunny_face_bow" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Flower Glasses" imageName:@"flower_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Medal" imageName:@"medal" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Necktie Graduation" imageName:@"necktie_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Nerd Glasses" imageName:@"nerd_glasses" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Pacifier Copy" imageName:@"pacifier-copy" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
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
             [[PGStickerItem alloc] initWithName:@"Ribbon Graduation" imageName:@"ribbon_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
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
             [[PGStickerItem alloc] initWithName:@"Carrot 2" imageName:@"carrot2" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
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
             [[PGStickerItem alloc] initWithName:@"Cat Celebrate" imageName:@"cat-celebrate" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti Graduation" imageName:@"confetti_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti" imageName:@"confetti" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
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
             [[PGStickerItem alloc] initWithName:@"Mom Child Cats" imageName:@"Mom_child_cats" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
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
             [[PGStickerItem alloc] initWithName:@"Flowers 2" imageName:@"Flowers2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Leaves" imageName:@"leaves" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Aster Flower" imageName:@"aster_flower" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner 2" imageName:@"banner_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner Copy" imageName:@"banner-copy" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bouquet" imageName:@"bouquet" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather Blue" imageName:@"feather_blue" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Floating Flowers 2" imageName:@"floating_flowers_2" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flower Leaves Element" imageName:@"flower_leaves_element" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flower Ring" imageName:@"flower_ring" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flower" imageName:@"flower" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Daisies" imageName:@"flowers_daisies" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Left" imageName:@"flowers_left" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Right" imageName:@"flowers_right" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hanging Lillies" imageName:@"hanging_lillies" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Lilly" imageName:@"lilly" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rose" imageName:@"rose" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rosebud Leaves" imageName:@"rosebud_leaves" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Daisies" imageName:@"three_daisies" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Flower Bunch" imageName:@"three_flower_bunch" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Rosebuds" imageName:@"three_rosebuds" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Tulips" imageName:@"tulips" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
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

- (NSArray<IMGLYSticker *> *)disneyCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Disney Headband D" imageName:@"disney_headband_d" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Disney Headband E" imageName:@"disney_headband_e" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker
             ];
}

@end
