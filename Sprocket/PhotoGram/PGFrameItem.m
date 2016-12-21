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
            frame.name = @"Christmas Polka Dot Frame";
            frame.accessibilityText = NSLocalizedString(@"Christmas Polka Dot Frame", nil);
            frame.imageName = @"xmasPolka_Frame_iOS";
            break;
        }
        case PGFrameRedTriangle: {
            frame.name = @"Red Triangle Frame";
            frame.accessibilityText = NSLocalizedString(@"Red Triangle Frame", nil);
            frame.imageName = @"RedTriangle_Frame_iOS";
            break;
        }
        case PGFrameSnow: {
            frame.name = @"Snow Frame";
            frame.accessibilityText = NSLocalizedString(@"Snow Frame", nil);
            frame.imageName = @"Snow_Frame_iOS";
            break;
        }
        case PGFrameStriped: {
            frame.name = @"Striped Frame";
            frame.accessibilityText = NSLocalizedString(@"Striped Frame", nil);
            frame.imageName = @"striped_Frame_iOS";
            break;
        }
        case PGFrameGrey: {
            frame.name = @"Grey Frame";
            frame.accessibilityText = NSLocalizedString(@"Grey Frame", nil);
            frame.imageName = @"Grey_Frame_iOS";
            break;
        }
        case PGFrameSanta: {
            frame.name = @"Santa Frame";
            frame.accessibilityText = NSLocalizedString(@"Santa Frame", nil);
            frame.imageName = @"Santa_Frame_iOS";
            break;
        }
        case PGFrameItemsBlueWaterColor: {
            frame.name = @"Water Blue Frame";
            frame.accessibilityText = NSLocalizedString(@"Water Blue Frame", nil);
            frame.imageName = @"3_blue_watercolor_frame";
            break;
        }
        case PGFrameItemsFloral: {
            frame.name = @"Floral Frame";
            frame.accessibilityText = NSLocalizedString(@"Floral Frame", nil);
            frame.imageName = @"6_floral_frame3";
            break;
        }
        case PGFrameItemsFloralTwo: {
            frame.name = @"Floral 2 Frame";
            frame.accessibilityText = NSLocalizedString(@"Floral 2 Frame", nil);
            frame.imageName = @"13_floral2_frame";
            break;
        }
        case PGFrameItemsGradient: {
            frame.name = @"Gradient Frame";
            frame.accessibilityText = NSLocalizedString(@"Gradient Frame", nil);
            frame.imageName = @"7_gradient_frame";
            break;
        }
        case PGFrameItemsGreenWaterColor: {
            frame.name = @"Green Water Color Frame";
            frame.accessibilityText = NSLocalizedString(@"Green Water Color Frame", nil);
            frame.imageName = @"10_green_watercolor_frame2";
            break;
        }
        case PGFrameItemsPinkSprayPaint: {
            frame.name = @"Pink Spray Paint Frame";
            frame.accessibilityText = NSLocalizedString(@"Pink Spray Paint Frame", nil);
            frame.imageName = @"2_pink_spraypaint_frame2";
            break;
        }
        case PGFrameItemsPolkadots: {
            frame.name = @"Polka Dots Frame";
            frame.accessibilityText = NSLocalizedString(@"Polka Dots Frame", nil);
            frame.imageName = @"9_polkadots_frame";
            break;
        }
        case PGFrameItemsRed: {
            frame.name = @"Red Frame";
            frame.accessibilityText = NSLocalizedString(@"Red Frame", nil);
            frame.imageName = @"5_Red_frame";
            break;
        }
        case PGFrameItemsTurquoise: {
            frame.name = @"Turquoise Frame";
            frame.accessibilityText = NSLocalizedString(@"Turquoise Frame", nil);
            frame.imageName = @"1_turquoise_frame";
            break;
        }
        case PGFrameItemsWhite: {
            frame.name = @"White Frame";
            frame.accessibilityText = NSLocalizedString(@"White Frame", nil);
            frame.imageName = @"4_white_frame";
            break;
        }
        case PGFrameItemsSloppy: {
            frame.name = @"Sloppy Frame";
            frame.accessibilityText = NSLocalizedString(@"Sloppy Frame", nil);
            frame.imageName = @"Sloppy_Frame_iOS";
            break;
        }
        case PGFrameItemsKraft: {
            frame.name = @"Kraft Frame";
            frame.accessibilityText = NSLocalizedString(@"Kraft Frame", nil);
            frame.imageName = @"Kraft_Frame_iOS";
            break;
        }
        case PGFrameItemsOrange: {
            frame.name = @"Orange Frame";
            frame.accessibilityText = NSLocalizedString(@"Orange Frame", nil);
            frame.imageName = @"Orange_Frame_iOS";
            break;
        }
        case PGFrameItemsWoodBottom: {
            frame.name = @"Wood Bottom Frame";
            frame.accessibilityText = NSLocalizedString(@"Wood Bottom Frame", nil);
            frame.imageName = @"Wood_Frame_iOS";
            break;
        }
        default:
            break;
    }
    
    return frame;
}

+ (PGFrameItem *)frameByAccessibilityText:(NSString *)accessibilityText
{
    PGFrameItem *frame = nil;
    
    for (NSInteger i=0; i<PGFrameItemsCount; ++i) {
        PGFrameItem *frameItem = [PGFrameItem frameItemByIndex:i];
        if ([accessibilityText isEqualToString:frameItem.accessibilityText]) {
            frame = frameItem;
            break;
        }
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
