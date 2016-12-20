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

const NSInteger PGFrameItemsCount = 20;

@implementation PGFrameItem

+ (PGFrameItem *)frameItemByIndex:(NSInteger)index {
    PGFrameItem *frame = [[PGFrameItem alloc] init];
    
    switch (index) {

        case PGFrameXmasPolkaDot: {
            frame.accessibilityText = @"Christmas Polka Dot Frame";
            frame.imageName = @"xmasPolka_Frame_iOS";
            break;
        }
        case PGFrameRedTriangle: {
            frame.accessibilityText = @"Red Triangle Frame";
            frame.imageName = @"RedTriangle_Frame_iOS";
            break;
        }
        case PGFrameSnow: {
            frame.accessibilityText = @"Snow Frame";
            frame.imageName = @"Snow_Frame_iOS";
            break;
        }
        case PGFrameStriped: {
            frame.accessibilityText = @"Striped Frame";
            frame.imageName = @"striped_Frame_iOS";
            break;
        }
        case PGFrameGrey: {
            frame.accessibilityText = @"Grey Frame";
            frame.imageName = @"Grey_Frame_iOS";
            break;
        }
        case PGFrameSanta: {
            frame.accessibilityText = @"Santa Frame";
            frame.imageName = @"Santa_Frame_iOS";
            break;
        }
        case PGFrameItemsBlueWaterColor: {
            frame.accessibilityText = @"Water Blue Frame";
            frame.imageName = @"3_blue_watercolor_frame";
            break;
        }
        case PGFrameItemsFloral: {
            frame.accessibilityText = @"Floral Frame";
            frame.imageName = @"6_floral_frame3";
            break;
        }
        case PGFrameItemsFloralTwo: {
            frame.accessibilityText = @"Floral 2 Frame";
            frame.imageName = @"13_floral2_frame";
            break;
        }
        case PGFrameItemsGradient: {
            frame.accessibilityText = @"Gradient Frame";
            frame.imageName = @"7_gradient_frame";
            break;
        }
        case PGFrameItemsGreenWaterColor: {
            frame.accessibilityText = @"Green Water Color Frame";
            frame.imageName = @"10_green_watercolor_frame2";
            break;
        }
        case PGFrameItemsPinkSprayPaint: {
            frame.accessibilityText = @"Pink Spray Paint Frame";
            frame.imageName = @"2_pink_spraypaint_frame2";
            break;
        }
        case PGFrameItemsPolkadots: {
            frame.accessibilityText = @"Polka Dots Frame";
            frame.imageName = @"9_polkadots_frame";
            break;
        }
        case PGFrameItemsRed: {
            frame.accessibilityText = @"Red Frame";
            frame.imageName = @"5_Red_frame";
            break;
        }
        case PGFrameItemsTurquoise: {
            frame.accessibilityText = @"Turquoise Frame";
            frame.imageName = @"1_turquoise_frame";
            break;
        }
        case PGFrameItemsWhite: {
            frame.accessibilityText = @"White Frame";
            frame.imageName = @"4_white_frame";
            break;
        }
        case PGFrameItemsSloppy: {
            frame.accessibilityText = @"Sloppy Frame";
            frame.imageName = @"Sloppy_Frame_iOS";
            break;
        }
        case PGFrameItemsKraft: {
            frame.accessibilityText = @"Kraft Frame";
            frame.imageName = @"Kraft_Frame_iOS";
            break;
        }
        case PGFrameItemsOrange: {
            frame.accessibilityText = @"Orange Frame";
            frame.imageName = @"Orange_Frame_iOS";
            break;
        }
        case PGFrameItemsWoodBottom: {
            frame.accessibilityText = @"Wood Bottom Frame";
            frame.imageName = @"Wood_Frame_iOS";
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
