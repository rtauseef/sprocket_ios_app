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

const NSInteger PGStickerItemsCount = 34;

@implementation PGStickerItem

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = [[PGStickerItem alloc] init];
    
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
            sticker = [PGStickerItem fallStickerItemByIndex:index];
            break;
    }
    
    return sticker;
}

+ (PGStickerItem *)fallStickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = [[PGStickerItem alloc] init];
    
    switch (index) {
        case PGStickerItemsPumpkin: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Pumpkin Sticker", nil);
            sticker.imageName = @"pumpkin";
            break;
        }
        case PGStickerItemsFootball: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Football Sticker", nil);
            sticker.imageName = @"Football";
            break;
        }
        case PGStickerItemsBanner2: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Banner Sticker", nil);
            sticker.imageName = @"banner2";
            break;
        }
        case PGStickerItemsFox: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Fox Sticker", nil);
            sticker.imageName = @"Fox";
            break;
        }
        case PGStickerItemsPilgrimHat: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Pilgrim Hat Sticker", nil);
            sticker.imageName = @"Pilgram-hat";
            break;
        }
        case PGStickerItemsWomanHat: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Woman Hat Sticker", nil);
            sticker.imageName = @"Woman-hat";
            break;
        }
        case PGStickerItemsEyes2: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Turkey Eyes Sticker", nil);
            sticker.imageName = @"Eyes2";
            break;
        }
        case PGStickerItemsLips: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Lips Sticker", nil);
            sticker.imageName = @"Lips";
            break;
        }
        case PGStickerItemsTurkeyHat2: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Turkey Sticker", nil);
            sticker.imageName = @"Turkey-hat2";
            break;
        }
        case PGStickerItemsLeaves: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Leaves Sticker", nil);
            sticker.imageName = @"leaves";
            break;
        }
        case PGStickerItemsHedgehog: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Hedgehog Sticker", nil);
            sticker.imageName = @"hedgehog";
            break;
        }
        case PGStickerItemsMushroomsB: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Mushrooms Sticker", nil);
            sticker.imageName = @"Mushrooms-b";
            break;
        }
        case PGStickerItemsPie: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Pie Sticker", nil);
            sticker.imageName = @"Pie";
            break;
        }
        case PGStickerItemsCocoa: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Cocoa Sticker", nil);
            sticker.imageName = @"Cocoa";
            break;
        }
        default:
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
