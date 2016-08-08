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

#import "PGFrameItem.h"

@implementation PGFrameItem

+ (PGFrameItem *)frameItemByIndex:(NSInteger)index {
    PGFrameItem *frame = [[PGFrameItem alloc] init];
    
    switch (index) {
        case PGFrameItemsBlue: {
            frame.accessibilityText = NSLocalizedString(@"Blue Frame", nil);
            frame.imageName = @"blue_frame";
            break;
        }
        case PGFrameItemsBlueGradient: {
            frame.accessibilityText = NSLocalizedString(@"Blue Gradient Frame", nil);
            frame.imageName = @"blue_gradient_frame";
            break;
        }
        case PGFrameItemsBlueWaterColor: {
            frame.accessibilityText = NSLocalizedString(@"Water Blue Frame", nil);
            frame.imageName = @"blue_watercolor_frame";
            break;
        }
        case PGFrameItemsFloral: {
            frame.accessibilityText = NSLocalizedString(@"Floral Frame", nil);
            frame.imageName = @"floral_frame";
            break;
        }
        case PGFrameItemsFloralTwo: {
            frame.accessibilityText = NSLocalizedString(@"Floral Frame", nil);
            frame.imageName = @"floral2_frame";
            break;
        }
        case PGFrameItemsGradient: {
            frame.accessibilityText = NSLocalizedString(@"Gradient Frame", nil);
            frame.imageName = @"gradient_frame";
            break;
        }
        case PGFrameItemsGreenSprayPaint: {
            frame.accessibilityText = NSLocalizedString(@"Green Spray Paint Frame", nil);
            frame.imageName = @"green_spraypaint_frame";
            break;
        }
        case PGFrameItemsGreenWaterColor: {
            frame.accessibilityText = NSLocalizedString(@"Green Water Color Frame", nil);
            frame.imageName = @"green_watercolor_frame";
            break;
        }
        case PGFrameItemsPink: {
            frame.accessibilityText = NSLocalizedString(@"Pink Frame", nil);
            frame.imageName = @"pink_frame";
            break;
        }
        case PGFrameItemsPinkSprayPaint: {
            frame.accessibilityText = NSLocalizedString(@"Pink Spray Paint Frame", nil);
            frame.imageName = @"pink_spraypaint_frame";
            break;
        }
        case PGFrameItemsPolkadots: {
            frame.accessibilityText = NSLocalizedString(@"Polka Dots Frame", nil);
            frame.imageName = @"polkadots_frame";
            break;
        }
        case PGFrameItemsPurple: {
            frame.accessibilityText = NSLocalizedString(@"Purple Frame", nil);
            frame.imageName = @"purple_frame";
            break;
        }
        case PGFrameItemsRed: {
            frame.accessibilityText = NSLocalizedString(@"Red Frame", nil);
            frame.imageName = @"Red_frame";
            break;
        }
        case PGFrameItemsTurquoise: {
            frame.accessibilityText = NSLocalizedString(@"Turquoise Frame", nil);
            frame.imageName = @"turquoise_frame";
            break;
        }
        case PGFrameItemsWhite: {
            frame.accessibilityText = NSLocalizedString(@"White Frame", nil);
            frame.imageName = @"white_frame";
            break;
        }
        default:
            break;
    }
    
    return frame;
}

- (UIImage *)thumbnailImage {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_TN", self.imageName]];
}

- (UIImage *)frameImage {
    return [UIImage imageNamed:self.imageName];
}

@end
