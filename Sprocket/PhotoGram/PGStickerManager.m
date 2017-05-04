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
//    IMGLYStickerCategory *cannesCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
//                                                                              imageURL:self.cannesCategoryStickers[1].thumbnailURL
//                                                                              stickers:[self cannesCategoryStickers]];
    
//    cannesCategory.accessibilityLabel = @"Cannes Category";

    IMGLYStickerCategory *summerCategory = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                              imageURL:self.summerCategoryStickers[1].thumbnailURL
                                                                              stickers:[self summerCategoryStickers]];
    
    summerCategory.accessibilityLabel = @"Summer Category";
    
    IMGLYStickerCategory *graduationCategory    = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.graduationCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self graduationCategoryStickers]];
    graduationCategory.accessibilityLabel = @"Graduation Category";
    
    IMGLYStickerCategory *faceCategory          = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.faceCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self faceCategoryStickers]];
    
    faceCategory.accessibilityLabel = @"Face Category";
    
    IMGLYStickerCategory *decorativeCategory    = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.decorativeCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self decorativeCategoryStickers]];
    
    decorativeCategory.accessibilityLabel = @"Decorative Category";
    
    IMGLYStickerCategory *foodCategory          = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.foodCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self foodCategoryStickers]];
    
    foodCategory.accessibilityLabel = @"Food Category";
    
    IMGLYStickerCategory *birthdayCategory      = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.birthdayCategoryStickers[3].thumbnailURL
                                                                                     stickers:[self birthdayCategoryStickers]];
    
    birthdayCategory.accessibilityLabel = @"Birthday Category";
    
    IMGLYStickerCategory *animalCategory        = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.animalCategoryStickers[8].thumbnailURL
                                                                                     stickers:[self animalCategoryStickers]];
    
    animalCategory.accessibilityLabel = @"Animal Category";
    
    IMGLYStickerCategory *natureCategory        = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.natureCategoryStickers[6].thumbnailURL
                                                                                     stickers:[self natureCategoryStickers]];
    
    natureCategory.accessibilityLabel = @"Nature Category";
    
    IMGLYStickerCategory *getWellCategory       = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.getWellCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self getWellCategoryStickers]];
    
    getWellCategory.accessibilityLabel = @"Get Well";
    
    return @[/*cannesCategory,*/ graduationCategory, summerCategory, faceCategory, decorativeCategory, foodCategory, birthdayCategory, animalCategory, natureCategory, getWellCategory];
}

#pragma mark - Stickers by category

- (NSArray<IMGLYSticker *> *)cannesCategoryStickers
{
    return @[
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

- (NSArray<IMGLYSticker *> *)graduationCategoryStickers
{
    return @[
             [[PGStickerItem alloc] initWithName:@"Graduation Glasses" imageName:@"g_glasses" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cap" imageName:@"cap" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Diploma" imageName:@"diploma" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Graduation Balloons" imageName:@"g_balloons" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti" imageName:@"confetti" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Graduation Horn" imageName:@"g_horn" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Medal" imageName:@"medal" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ribbon" imageName:@"ribbon" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Books" imageName:@"books" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pencil" imageName:@"pencil" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Owl" imageName:@"g_owl" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Nerd Glasses" imageName:@"nerd_glasses" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cap Graduation" imageName:@"cap_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Diploma Doodle" imageName:@"diploma_doodle" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti Graduation" imageName:@"confetti_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Necktie Graduation" imageName:@"necktie_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bowtie Graduation" imageName:@"bowtie_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Medal Gratuation" imageName:@"medal_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Book Stack" imageName:@"book_stack" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pencil Graduation" imageName:@"pencil_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ribbon Graduation" imageName:@"ribbon_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flying Caps Graduation" imageName:@"flying_caps_graduation" tintMode:IMGLYStickerTintModeSolid andPackageName:nil].imglySticker,
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
             [[PGStickerItem alloc] initWithName:@"Flowers" imageName:@"flowers" tintMode:IMGLYStickerTintModeNone andPackageName:nil].imglySticker,
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
             ];
}

@end
