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

const NSInteger PGStickerItemsCount = 23;

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
        case PGStickerItemsHeartPixel: {
            sticker.accessibilityText = NSLocalizedString(@"Heart Pixel Sticker", nil);
            sticker.imageName = @"heartPixel";
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
        case PGStickerItemsCloud: {
            sticker.accessibilityText = NSLocalizedString(@"Cloud Sticker", nil);
            sticker.imageName = @"cloud";
            break;
        }
        case PGStickerItemsCupcake: {
            sticker.accessibilityText = NSLocalizedString(@"Cupcake Sticker", nil);
            sticker.imageName = @"cupcake";
            break;
        }
        case PGStickerItemsIceCreamCone: {
            sticker.accessibilityText = NSLocalizedString(@"Ice Cream Cone Sticker", nil);
            sticker.imageName = @"icecreamcone";
            break;
        }
        case PGStickerItemsCandy: {
            sticker.accessibilityText = NSLocalizedString(@"Candy Sticker", nil);
            sticker.imageName = @"candy";
            break;
        }
        case PGStickerItemsCat: {
            sticker.accessibilityText = NSLocalizedString(@"Cat Sticker", nil);
            sticker.imageName = @"cat";
            break;
        }
        case PGStickerItemsBird: {
            sticker.accessibilityText = NSLocalizedString(@"Bird Sticker", nil);
            sticker.imageName = @"bird";
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
        case PGStickerItemsLOL: {
            sticker.accessibilityText = NSLocalizedString(@"LOL Sticker", nil);
            sticker.imageName = @"LOL";
            break;
        }
        
        default:
            break;
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
