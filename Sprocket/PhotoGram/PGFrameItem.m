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
            frame.accessibilityText = NSLocalizedString(@"Christmas Polka Dot Frame", nil);
            frame.imageName = @"xmasPolka_Frame_iOS";
            break;
        }
        case PGFrameRedTriangle: {
            frame.accessibilityText = NSLocalizedString(@"Red Triangle Frame", nil);
            frame.imageName = @"RedTriangle_Frame_iOS";
            break;
        }
        case PGFrameSnow: {
            frame.accessibilityText = NSLocalizedString(@"Snow Frame", nil);
            frame.imageName = @"Snow_Frame_iOS";
            break;
        }
        case PGFrameStriped: {
            frame.accessibilityText = NSLocalizedString(@"Striped Frame", nil);
            frame.imageName = @"striped_Frame_iOS";
            break;
        }
        case PGFrameGrey: {
            frame.accessibilityText = NSLocalizedString(@"Grey Frame", nil);
            frame.imageName = @"Grey_Frame_iOS";
            break;
        }
        case PGFrameSanta: {
            frame.accessibilityText = NSLocalizedString(@"Santa Frame", nil);
            frame.imageName = @"Santa_Frame_iOS";
            break;
        }
        case PGFrameItemsBlueWaterColor: {
            frame.accessibilityText = NSLocalizedString(@"Water Blue Frame", nil);
            frame.imageName = @"3_blue_watercolor_frame";
            break;
        }
        case PGFrameItemsFloral: {
            frame.accessibilityText = NSLocalizedString(@"Floral Frame", nil);
            frame.imageName = @"6_floral_frame3";
            break;
        }
        case PGFrameItemsFloralTwo: {
            frame.accessibilityText = NSLocalizedString(@"Floral 2 Frame", nil);
            frame.imageName = @"13_floral2_frame";
            break;
        }
        case PGFrameItemsGradient: {
            frame.accessibilityText = NSLocalizedString(@"Gradient Frame", nil);
            frame.imageName = @"7_gradient_frame";
            break;
        }
        case PGFrameItemsGreenWaterColor: {
            frame.accessibilityText = NSLocalizedString(@"Green Water Color Frame", nil);
            frame.imageName = @"10_green_watercolor_frame2";
            break;
        }
        case PGFrameItemsPinkSprayPaint: {
            frame.accessibilityText = NSLocalizedString(@"Pink Spray Paint Frame", nil);
            frame.imageName = @"2_pink_spraypaint_frame2";
            break;
        }
        case PGFrameItemsPolkadots: {
            frame.accessibilityText = NSLocalizedString(@"Polka Dots Frame", nil);
            frame.imageName = @"9_polkadots_frame";
            break;
        }
        case PGFrameItemsRed: {
            frame.accessibilityText = NSLocalizedString(@"Red Frame", nil);
            frame.imageName = @"5_Red_frame";
            break;
        }
        case PGFrameItemsTurquoise: {
            frame.accessibilityText = NSLocalizedString(@"Turquoise Frame", nil);
            frame.imageName = @"1_turquoise_frame";
            break;
        }
        case PGFrameItemsWhite: {
            frame.accessibilityText = NSLocalizedString(@"White Frame", nil);
            frame.imageName = @"4_white_frame";
            break;
        }
        case PGFrameItemsSloppy: {
            frame.accessibilityText = NSLocalizedString(@"Sloppy Frame", nil);
            frame.imageName = @"Sloppy_Frame_iOS";
            break;
        }
        case PGFrameItemsKraft: {
            frame.accessibilityText = NSLocalizedString(@"Kraft Frame", nil);
            frame.imageName = @"Kraft_Frame_iOS";
            break;
        }
        case PGFrameItemsOrange: {
            frame.accessibilityText = NSLocalizedString(@"Orange Frame", nil);
            frame.imageName = @"Orange_Frame_iOS";
            break;
        }
        case PGFrameItemsWoodBottom: {
            frame.accessibilityText = NSLocalizedString(@"Wood Bottom Frame", nil);
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
