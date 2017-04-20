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

@property (nonatomic, strong) NSMutableArray *stickers;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.stickers = [NSMutableArray array];
    
    if ([NSLocale isChinese]) {
        [self.stickers addObjectsFromArray:[self chinaStickers]];
    } else {
        [self.stickers addObjectsFromArray:[self standardUSStickers]];
    }
}

- (NSArray<IMGLYStickerCategory *> *)IMGLYStickersCategories
{
    IMGLYStickerCategory *mothersDayCategory    = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.mothersDayCategoryStickers[7].thumbnailURL
                                                                                     stickers:[self mothersDayCategoryStickers]];
    
    IMGLYStickerCategory *graduationCategory    = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.graduationCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self graduationCategoryStickers]];
    
    IMGLYStickerCategory *faceCategory          = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.faceCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self faceCategoryStickers]];
    
    IMGLYStickerCategory *decorativeCategory    = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.decorativeCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self decorativeCategoryStickers]];
    
    IMGLYStickerCategory *foodCategory          = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.foodCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self foodCategoryStickers]];
    
    IMGLYStickerCategory *birthdayCategory      = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.birthdayCategoryStickers[3].thumbnailURL
                                                                                     stickers:[self birthdayCategoryStickers]];
    
    IMGLYStickerCategory *animalCategory        = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.animalCategoryStickers[0].thumbnailURL
                                                                                     stickers:[self animalCategoryStickers]];
    
    IMGLYStickerCategory *natureCategory        = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.natureCategoryStickers[6].thumbnailURL
                                                                                     stickers:[self natureCategoryStickers]];
    
    IMGLYStickerCategory *getWellCategory       = [[IMGLYStickerCategory alloc] initWithTitle:@""
                                                                                     imageURL:self.getWellCategoryStickers[1].thumbnailURL
                                                                                     stickers:[self getWellCategoryStickers]];
    
    return @[mothersDayCategory, graduationCategory, faceCategory, decorativeCategory, foodCategory, birthdayCategory, animalCategory, natureCategory, getWellCategory];
}

#pragma mark - Stickers by category

- (NSArray<IMGLYSticker *> *)mothersDayCategoryStickers {
    return @[
             [[PGStickerItem alloc] initWithName:@"Flowers Left" imageName:@"flowers_left" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mother's Day" imageName:@"mothers_day" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner Flowers" imageName:@"banner copy" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner Flowers 2" imageName:@"banner_2" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Right" imageName:@"flowers_right" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flowers Daisies" imageName:@"flowers_daisies" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flower" imageName:@"flower" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Mom" imageName:@"heart_mom" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pacifier" imageName:@"pacifier-copy" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bouquet" imageName:@"bouquet" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rose" imageName:@"rose" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Snails" imageName:@"snails" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mother Giraffe" imageName:@"mother_giraffe" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mother Turtle" imageName:@"mother_turtle" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather Color" imageName:@"feather_color" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Girl Flower" imageName:@"girl_flower" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Envelope" imageName:@"envelope" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Silhoutte" imageName:@"silhouette" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mom Tattoo" imageName:@"mom_tattoo" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Rosebuds" imageName:@"three_rosebuds" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Rosebud Leaves" imageName:@"rosebud_leaves" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Flowers Bunch" imageName:@"three_flower_bunch" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Three Daisies" imageName:@"three_daisies" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"We Love You" imageName:@"we_love_you" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Mom Child Cats" imageName:@"Mom_child_cats" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Aster Flower" imageName:@"aster_flower" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Envelope Flowers" imageName:@"envelope_flowers" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Holding Flowers" imageName:@"cat_holding_flwoers" andPackageName:nil].imglySticker,
             ];
}


- (NSArray<IMGLYSticker *> *)graduationCategoryStickers {
    return @[
             [[PGStickerItem alloc] initWithName:@"Graduation Glasses" imageName:@"g_glasses" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cap" imageName:@"cap" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Diploma" imageName:@"diploma" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Graduation Balloons" imageName:@"g_balloons" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti" imageName:@"confetti" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Graduation Horn" imageName:@"g_horn" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Medal" imageName:@"medal" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ribbon" imageName:@"ribbon" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Books" imageName:@"books" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pencil" imageName:@"pencil" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Owl" imageName:@"g_owl" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Nerd Glasses" imageName:@"nerd_glasses" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cap Graduation" imageName:@"cap_graduation" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Diploma Doodle" imageName:@"diploma_doodle" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Confetti Graduation" imageName:@"confetti_graduation" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Necktie Graduation" imageName:@"necktie_graduation" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bowtie Graduation" imageName:@"bowtie_graduation" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Medal Gratuation" imageName:@"medal_graduation" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Book Stack" imageName:@"book_stack" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pencil Graduation" imageName:@"pencil_graduation" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ribbon Graduation" imageName:@"ribbon_graduation" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Flying Caps Graduation" imageName:@"flying_caps_graduation" andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)faceCategoryStickers {
    return @[
            [[PGStickerItem alloc] initWithName:@"Aviator Glasses Color" imageName:@"aviator-glasses-color" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Lips" imageName:@"Lips" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat Glasses" imageName:@"catglasses" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses 1" imageName:@"glasses_1" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses" imageName:@"glasses" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Bunny Ears Flowers" imageName:@"bunny_ears_flowers" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat Ears" imageName:@"catears" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Crown" imageName:@"crown" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Sunglasses Frogskin" imageName:@"sunglasses_frogskin" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Aviator Glasses" imageName:@"aviator_glasses" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Rabbit Mask" imageName:@"rabbit-mask" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat Whiskers" imageName:@"catwhiskers" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Birthday Hat" imageName:@"birthdayHat" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Party Hat" imageName:@"Party-Hat" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Blossom" imageName:@"glasses_blossom" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Sun Hat" imageName:@"sun_hat" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Derby" imageName:@"Derby" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Red" imageName:@"Glasses-red" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Blinds" imageName:@"Glasses-blinds" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cat on Head" imageName:@"cat-on-head" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Panda Mask" imageName:@"panda-mask" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Devil Horns" imageName:@"devilhorns" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Sunglasses" imageName:@"sunglasses" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Mustache Brown" imageName:@"Mustache-brown" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Mustache Dark" imageName:@"Mustache-dark" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Beard" imageName:@"Beard" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Glasses Football" imageName:@"glasses_football" andPackageName:nil].imglySticker,
            ];
}

- (NSArray<IMGLYSticker *> *)decorativeCategoryStickers {
    return @[
             [[PGStickerItem alloc] initWithName:@"Heart Garland" imageName:@"heart-garland" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hearts" imageName:@"v_hearts" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart 2" imageName:@"heart_2" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Hearts Doodle" imageName:@"hearts" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Express" imageName:@"heartExpress" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Xoxo" imageName:@"xoxo" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Diamond" imageName:@"diamond" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Banner" imageName:@"banner" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"3D diamond 1" imageName:@"3d-diamond-1" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"3D diamond 2" imageName:@"3d-diamond-2" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather" imageName:@"feather" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Peace" imageName:@"peace" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Thumbs Up" imageName:@"thumbs-up" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Fist" imageName:@"fist" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Unicorn" imageName:@"Unicorn" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Wings" imageName:@"heart_wings" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Smiley" imageName:@"smiley" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart" imageName:@"v_heart" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Pixel" imageName:@"heartPixel" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Heart Arrow" imageName:@"heart_arrow" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Arrow" imageName:@"arrow" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather 2" imageName:@"feather2" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Alarm Clock" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@“Skateboard" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Unicorn Float" imageName:@"unicorn_float" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Beach Ball Colored" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Beach Umbrella" imageName:@"beach_umbrella" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Volley Ball" imageName:@"volleyball" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Bike Cruiser" imageName:@"bike_cruiser" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Swim Fins" imageName:@"swim_fins" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Scuba" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Plane" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"School Bus" imageName:@"schoolbus" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Travel Car" imageName:@"travel_car_bug" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Trailer" imageName:@"trailer" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Travel Car Woody" imageName:@"travel_car_woody" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Surf Board" imageName:@"surfboard" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Football" imageName:@"Football" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Word Cloud Grumble" imageName:@"word-cloud-grumble" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Skull" imageName:@"skull" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"LOL" imageName:@"LOL" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"OMG" imageName:@"OMG" andPackageName:nil].imglySticker,
             ];
}


- (NSArray<IMGLYSticker *> *)foodCategoryStickers {
    return @[
             [[PGStickerItem alloc] initWithName:@"Frappuccino" imageName:@"Frappuccino" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Doughnut" imageName:@"doughnut" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Pizza" imageName:@"pizza" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Taco 2" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Watermelon" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Pineapple" imageName:@"" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Bacon n egg" imageName:@"bacon_egg" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Soda Can" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Ice Cream Cone" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Candy" imageName:@"" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cupcake" imageName:@"cupcake" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sundae" imageName:@"sundae" andPackageName:nil].imglySticker,
//              [[PGStickerItem alloc] initWithName:@"Cupcake 2" imageName:@"" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Ice Cream Tub" imageName:@"icecream_tub" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Coffee" imageName:@"cat-coffee" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cat Fries" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Ketchup Hot Dog" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Apple Angry" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Spoon" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Fork" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Soda" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Turkey" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cocoa" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Oranges" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Pie" imageName:@"" andPackageName:nil].imglySticker,
             ];
}


- (NSArray<IMGLYSticker *> *)birthdayCategoryStickers {
    return @[
             [[PGStickerItem alloc] initWithName:@"Balloons 2" imageName:@"balloons2" andPackageName:nil].imglySticker,
//            [[PGStickerItem alloc] initWithName:@"Banner" imageName:@"banner" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Birthday Hat" imageName:@"birthdayHat" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cake" imageName:@"cake" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Crown" imageName:@"crown" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cupcake" imageName:@"cupcake" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Fireworks" imageName:@"fireworks" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Gift" imageName:@"gift" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Gift Dog" imageName:@"gift-dog" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Horn" imageName:@"horn" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Party Hat" imageName:@"" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Stars" imageName:@"stars" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Balloons" imageName:@"" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cat Celebrate" imageName:@"" andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)animalCategoryStickers {
    return @[
             [[PGStickerItem alloc] initWithName:@"Cat Face" imageName:@"cat" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cat" imageName:@"cat" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Dog" imageName:@"dog" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Sloth" imageName:@"sloth" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Bird" imageName:@"bird" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Fox" imageName:@"fox" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Sloth" imageName:@"sloth" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Hedgehog" imageName:@"Hedgehog" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Owl" imageName:@"owl" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Panda" imageName:@"Panda" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Panda Mask" imageName:@"panda-mask" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Koala" imageName:@"koala" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Glasses" imageName:@"catglasses" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Rabbit" imageName:@"rabbit" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Scary Cat" imageName:@"scarycat" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat on Head" imageName:@"cat-on-head" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Shock" imageName:@"cat-shock" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cat Grumble" imageName:@"cat-grumble" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Cat Fries" imageName:@"cat-fries" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Spider" imageName:@"spider" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Bird Color" imageName:@"bird" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Butterfly" imageName:@"butterfly" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Pig" imageName:@"pig" andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)natureCategoryStickers {
    return @[
             [[PGStickerItem alloc] initWithName:@"Feather" imageName:@"feather" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Hibiscus" imageName:@"hibiscus" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Plum Blossom" imageName:@"plum-blossom" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Rosebud" imageName:@"rosebud" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Palm Tree 2" imageName:@"palm-tree-2" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Rainbow 2" imageName:@"rainbow_2" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Sun" imageName:@"sun" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Sun Face" imageName:@"sun_face" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Palm Tree" imageName:@"palmtree" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Wave" imageName:@"wave" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Flowers" imageName:@"flowers" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Heart Bouquet" imageName:@"heart-bouquet" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Star" imageName:@"starhp" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Stars" imageName:@"stars" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Star Yellow" imageName:@"star_yeallow" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Moon" imageName:@"moon" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Mushrooms" imageName:@"mushrooms-b" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cloud Sun" imageName:@"cloud_sun" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Cloud Angry" imageName:@"cloud_angry" andPackageName:nil].imglySticker,
            [[PGStickerItem alloc] initWithName:@"Cloud Sad" imageName:@"cloud_sad" andPackageName:nil].imglySticker,
             [[PGStickerItem alloc] initWithName:@"Feather 2" imageName:@"feather2" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Flowers" imageName:@"flowers" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Leaves" imageName:@"leaves" andPackageName:nil].imglySticker,
             ];
}

- (NSArray<IMGLYSticker *> *)getWellCategoryStickers {
    return @[
              [[PGStickerItem alloc] initWithName:@"Band aid 2" imageName:@"band-aid2" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Kleenex" imageName:@"kleenex" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Measles" imageName:@"measles" andPackageName:nil].imglySticker,
//             [[PGStickerItem alloc] initWithName:@"Medicine" imageName:@"medicine" andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Love Monster" imageName:@"love_monster" andPackageName:nil].imglySticker,
              [[PGStickerItem alloc] initWithName:@"Letter" imageName:@"letter" andPackageName:nil].imglySticker,
             ];
}

- (NSArray *)chinaStickers
{   
    return @[
             [[PGStickerItem alloc] initWithName:@"Cat Glasses" imageName:@"catglasses" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cat Whiskers" imageName:@"catwhiskers" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cat Ears" imageName:@"catears" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Glasses" imageName:@"glasses" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Crown" imageName:@"crown" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Rabbit Mask" imageName:@"rabbit-mask" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Birthday Hat" imageName:@"birthdayHat" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cat on Head" imageName:@"cat-on-head" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Thought Bubble" imageName:@"thought_bubble" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Word Cloud Grumble" imageName:@"word-cloud-grumble" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Sunglasses" imageName:@"sunglasses" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Panda Mask" imageName:@"panda-mask" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Frappuccino" imageName:@"Frappuccino" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Glasses 1" imageName:@"glasses_1" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Glasses Blossom" imageName:@"glasses_blossom" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Panda" imageName:@"Panda" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Balloons 2" imageName:@"balloons2" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Band aid 2" imageName:@"band-aid2" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Hearts" imageName:@"hearts" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Heart Express" imageName:@"heartExpress" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Heart Banner" imageName:@"heart_banner" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Heart" imageName:@"v_heart" andPackageName:@"Valentines"],
             [[PGStickerItem alloc] initWithName:@"Stars" imageName:@"stars" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Arrow" imageName:@"arrow" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Feather" imageName:@"feather" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Feather 2" imageName:@"feather2" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Star" imageName:@"starhp" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Thumbs Up" imageName:@"thumbs-up" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Peace" imageName:@"peace" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Smiley" imageName:@"smiley" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cupcake" imageName:@"cupcake" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Diamond" imageName:@"diamond" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"3D diamond 2" imageName:@"3d-diamond-2" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"3D diamond 1" imageName:@"3d-diamond-1" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cat Face" imageName:@"cat" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cat Shock" imageName:@"cat-shock" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cloud Sad" imageName:@"cloud_sad" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Cat Coffee" imageName:@"cat-coffee" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Love Monster" imageName:@"love_monster" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"School Bus" imageName:@"schoolbus" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Doughnut" imageName:@"doughnut" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Pizza" imageName:@"pizza" andPackageName:nil],
             [[PGStickerItem alloc] initWithName:@"Bacon n egg" imageName:@"bacon_egg" andPackageName:nil],
             ];
}

- (NSArray *)standardUSStickers
{
    NSString *packageName = nil;
    
    return @[
             [[PGStickerItem alloc] initWithName:@"Hearts Doodle" imageName:@"hearts" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Xoxo" imageName:@"xoxo" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Heart Express" imageName:@"heartExpress" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Heart" imageName:@"v_heart" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Glasses 1" imageName:@"glasses_1" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Heart 2" imageName:@"heart_2" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Hearts" imageName:@"v_hearts" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Heart Garland" imageName:@"heart-garland" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Valentines Xoxo" imageName:@"v_xoxo" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Heart Wings" imageName:@"heart_wings" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Palm Tree" imageName:@"palmtree" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Beach Ball" imageName:@"beachball" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Wave" imageName:@"wave" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Beach Umbrella" imageName:@"beach_umbrella" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Sun Face" imageName:@"sun_face" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Sunglasses Frogskin" imageName:@"sunglasses_frogskin" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Aviator Glasses" imageName:@"aviator_glasses" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Glasses" imageName:@"glasses" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Bunny Ears Flowers" imageName:@"bunny_ears_flowers" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Cat Glasses" imageName:@"catglasses" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Cat Ears" imageName:@"catears" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Scuba Mask" imageName:@"scuba_mask" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Swim Fins" imageName:@"swim_fins" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Volley Ball" imageName:@"volleyball" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Trailer" imageName:@"trailer" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Travel Car" imageName:@"travel_car_bug" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Travel Car Woody" imageName:@"travel_car_woody" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Bike Cruiser" imageName:@"bike_cruiser" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Airplane" imageName:@"airplane" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Soda Straw" imageName:@"soda_straw" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Sundae" imageName:@"sundae" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Ice Cream Tub" imageName:@"icecream_tub" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Cupcake" imageName:@"cupcake" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"BBQ" imageName:@"bbq" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Unicorn Float" imageName:@"unicorn_float" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Surf Board" imageName:@"surfboard" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Crown" imageName:@"crown" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Birthday Hat" imageName:@"birthdayHat" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Diamond" imageName:@"diamond" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Feather" imageName:@"feather" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Stars" imageName:@"stars" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Star" imageName:@"starhp" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Cat Face" imageName:@"cat" andPackageName:packageName],
             [[PGStickerItem alloc] initWithName:@"Smiley" imageName:@"smiley" andPackageName:packageName],
             ];
}

- (NSArray<IMGLYSticker *> *)imglyStickers {
    NSMutableArray<IMGLYSticker *> *stickers = [[NSMutableArray alloc] init];

    for (PGStickerItem *sticker in self.stickers) {
        [stickers addObject:sticker.imglySticker];
    }

    return stickers;
}

@end
