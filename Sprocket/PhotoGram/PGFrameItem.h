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

#import <Foundation/Foundation.h>

extern const NSInteger PGFrameItemsCount;

typedef NS_ENUM (NSInteger, PGFrameItems){
    PGFrameXmasPolkaDot,
    PGFrameRedTriangle,
    PGFrameSnow,
    PGFrameStriped,
    PGFrameGrey,
    PGFrameSanta,
    PGFrameItemsWhite,
    PGFrameItemsKraft,
    PGFrameItemsFloral,
    PGFrameItemsOrange,
    PGFrameItemsPolkadots,
    PGFrameItemsBlueWaterColor,
    PGFrameItemsWoodBottom,
    PGFrameItemsGradient,
    PGFrameItemsSloppy,
    PGFrameItemsTurquoise,
    PGFrameItemsRed,
    PGFrameItemsGreenWaterColor,
    PGFrameItemsFloralTwo,
    PGFrameItemsPinkSprayPaint
};

@interface PGFrameItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *name;

+ (PGFrameItem *)frameItemByIndex:(NSInteger)index;
+ (PGFrameItem *)frameByAccessibilityText:(NSString *)accessibilityText;
- (UIImage *)thumbnailImage;
- (UIImage *)frameImage;

@end
