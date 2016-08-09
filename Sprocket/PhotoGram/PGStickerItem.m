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

@implementation PGStickerItem

+ (PGStickerItem *)stickerItemByIndex:(NSInteger)index {
    PGStickerItem *sticker = [[PGStickerItem alloc] init];
    
    switch (index) {
        case PGStickerItemsCatGlasses: {
            sticker.accessibilityText = NSLocalizedString(@"Cat Glasses Sticker", nil);
            sticker.imageName = @"catglasses";
            break;
        }
        case PGStickerItemsCrown: {
            sticker.accessibilityText = NSLocalizedString(@"Crown Sticker", nil);
            sticker.imageName = @"crown";
            break;
        }
        case PGStickerItemsHearts: {
            sticker.accessibilityText = NSLocalizedString(@"Hearts Sticker", nil);
            sticker.imageName = @"hearts";
            break;
        }
        case PGStickerItemsOMG: {
            sticker.accessibilityText = NSLocalizedString(@"OMG Sticker", nil);
            sticker.imageName = @"OMG";
            break;
        }
        case PGStickerItemsStar: {
            sticker.accessibilityText = NSLocalizedString(@"Star Sticker", nil);
            sticker.imageName = @"star";
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
