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
    PGFrameItemsBlue,
    PGFrameItemsBlueGradient,
    PGFrameItemsBlueWaterColor,
    PGFrameItemsFloral,
    PGFrameItemsFloralTwo,
    PGFrameItemsGradient,
    PGFrameItemsGreenSprayPaint,
    PGFrameItemsGreenWaterColor,
    PGFrameItemsPink,
    PGFrameItemsPinkSprayPaint,
    PGFrameItemsPolkadots,
    PGFrameItemsPurple,
    PGFrameItemsRed,
    PGFrameItemsTurquoise,
    PGFrameItemsWhite,
};

@interface PGFrameItem : NSObject

@property (nonatomic, strong) NSString *accessibilityText;
@property (nonatomic, strong) NSString *imageName;

+ (PGFrameItem *)frameItemByIndex:(NSInteger)index;
- (UIImage *)thumbnailImage;
- (UIImage *)frameImage;

@end
