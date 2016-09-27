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

const NSInteger PGStickerItemsCount = 45;

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
            sticker = [PGStickerItem fallStickerItemByIndex:index];
            break;
    }
    
    return sticker;
}

+ (PGStickerItem *)fallStickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = [[PGStickerItem alloc] init];

    switch (index) {
        case PGStickerItemsFallCatWhiskers: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Cat Whiskers Sticker", nil);
            sticker.imageName = @"catwhiskers";
            break;
        }
            
        case PGStickerItemsFallDodMask: {
            sticker.accessibilityText = NSLocalizedString(@"DOD Mask Sticker", nil);
            sticker.imageName = @"DODmask";
            break;
        }

        case PGStickerItemsFallCatEyes: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Cat Eyes Sticker", nil);
            sticker.imageName = @"cateyes";
            break;
        }

        case PGStickerItemsFallJasonMask: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Jason Mask Sticker", nil);
            sticker.imageName = @"jasonmask";
            break;
        }

        case PGStickerItemsFallDodEyes: {
            sticker.accessibilityText = NSLocalizedString(@"Fall DOD Eyes Sticker", nil);
            sticker.imageName = @"DODeyes";
            break;
        }

        case PGStickerItemsFall3Eyes: {
            sticker.accessibilityText = NSLocalizedString(@"Fall 3 Eyes Sticker", nil);
            sticker.imageName = @"threeeyes";
            break;
        }

        case PGStickerItemsFallFangs: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Fangs Sticker", nil);
            sticker.imageName = @"fangs";
            break;
        }

        case PGStickerItemsFallEyeball: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Eyeball Sticker", nil);
            sticker.imageName = @"eyeball";
            break;
        }

        case PGStickerItemsFallDevilHorns: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Devil Horns Sticker", nil);
            sticker.imageName = @"devilhorns";
            break;
        }

        case PGStickerItemsFallHalloweenHat: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Halloween Hat Sticker", nil);
            sticker.imageName = @"HalloweenHat";
            break;
        }

        case PGStickerItemsFallSpiderWeb: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Spider Web Sticker", nil);
            sticker.imageName = @"spiderweb";
            break;
        }

        case PGStickerItemsFallMoon: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Moon Sticker", nil);
            sticker.imageName = @"moon";
            break;
        }

        case PGStickerItemsFallMoonFace: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Moon Face Sticker", nil);
            sticker.imageName = @"moonface";
            break;
        }

        case PGStickerItemsFallSkull: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Skull Sticker", nil);
            sticker.imageName = @"skull";
            break;
        }

        case PGStickerItemsFallPumpkin: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Pumpkin Sticker", nil);
            sticker.imageName = @"pumpkin";
            break;
        }

        case PGStickerItemsFallBat: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Bat Sticker", nil);
            sticker.imageName = @"bat";
            break;
        }

        case PGStickerItemsFallGhost: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Ghost Sticker", nil);
            sticker.imageName = @"ghost";
            break;
        }

        case PGStickerItemsFallCandyCorn: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Candy Corn Sticker", nil);
            sticker.imageName = @"candycorn";
            break;
        }

        case PGStickerItemsFallSpider: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Spider Sticker", nil);
            sticker.imageName = @"spider";
            break;
        }

        case PGStickerItemsFallScaryCat: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Scary Cat Sticker", nil);
            sticker.imageName = @"scarycat";
            break;
        }

        case PGStickerItemsFallLeaf3: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Leaf 3 Sticker", nil);
            sticker.imageName = @"leaf3";
            break;
        }

        case PGStickerItemsFallOwl: {
            sticker.accessibilityText = NSLocalizedString(@"Fall Owl Sticker", nil);
            sticker.imageName = @"owl";
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
