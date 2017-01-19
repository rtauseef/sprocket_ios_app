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

const NSInteger PGFrameItemsStandardCount = 14;
const NSInteger PGFrameItemsValentinesCount = 6;

@implementation PGFrameItem

+ (NSInteger)frameCount
{
    NSInteger numFrames = PGFrameItemsStandardCount + PGFrameItemsValentinesCount;
    
    return numFrames;
}

+ (PGFrameItem *)frameItemByIndex:(NSInteger)index {
    PGFrameItem *frame = nil;
    NSInteger frameOffset = 0;
    
    frame = [self valentinesFrameItemByIndex:index];
    frameOffset = PGFrameItemsValentinesCount;
    
    if (nil == frame) {
        index -= frameOffset;
        frame = [self standardFrameItemByIndex:index];
    }
    
    return frame;
}

+ (PGFrameItem *)standardFrameItemByIndex:(NSInteger)index
{
    PGFrameItem *frame = [[PGFrameItem alloc] init];
    
    switch (index) {
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
            frame = nil;
            break;
    }
    
    return frame;
}

+ (PGFrameItem *)valentinesFrameItemByIndex:(NSInteger)index
{
    PGFrameItem *frame = [[PGFrameItem alloc] init];
    
    switch (index) {
        case PGFrameItemsValentinesHeart: {
            frame.name = @"Valentines Hearts Frame";
            frame.accessibilityText = NSLocalizedString(@"Valentines Hearts Frame", nil);
            frame.imageName = @"Hearts_Frame_iOS";
            break;
        }
        case PGFrameItemsValentinesPinkPolka: {
            frame.name = @"Valentines Pink Polka Frame";
            frame.accessibilityText = NSLocalizedString(@"Valentines Pink Polka Frame", nil);
            frame.imageName = @"PinkPolka_Frame_iOS";
            break;
        }
        case PGFrameItemsValentinesRed: {
            frame.name = @"Valentines Red Frame";
            frame.accessibilityText = NSLocalizedString(@"Valentines Red Frame", nil);
            frame.imageName = @"Red_Frame_iOS";
            break;
        }
        case PGFrameItemsValentinesHeartsOverlay: {
            frame.name = @"Valentines Hearts Overlay Frame";
            frame.accessibilityText = NSLocalizedString(@"Valentines Hearts Overlay Frame", nil);
            frame.imageName = @"HeartsOverlay_Frame_iOS";
            break;
        }
        case PGFrameItemsValentinesPinkWatercolor: {
            frame.name = @"Valentines Pink Watercolor Frame";
            frame.accessibilityText = NSLocalizedString(@"Valentines Pink Watercolor Frame", nil);
            frame.imageName = @"PinkWatercolor_Frame_iOS";
            break;
        }
        case PGFrameItemsValentinesRedStripes: {
            frame.name = @"Valentines Red Stripes Frame";
            frame.accessibilityText = NSLocalizedString(@"Valentines Red Stripes Frame", nil);
            frame.imageName = @"RedStripes_Frame_iOS";
            break;
        }
        default:
            frame = nil;
            break;
    }
    
    return frame;
}

+ (PGFrameItem *)frameByAccessibilityText:(NSString *)accessibilityText
{
    PGFrameItem *frame = nil;
    NSInteger frameCount = [PGFrameItem frameCount];
    
    for (NSInteger i = 0; i < frameCount; ++i) {
        PGFrameItem *frameItem = [PGFrameItem frameItemByIndex:i];
        if ([accessibilityText isEqualToString:frameItem.accessibilityText]) {
            frame = frameItem;
            break;
        }
    }

    return frame;
}

- (UIImage *)thumbnailImage
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@_TN", self.imageName]];
}

- (UIImage *)frameImage
{
    return [UIImage imageNamed:self.imageName];
}

@end
