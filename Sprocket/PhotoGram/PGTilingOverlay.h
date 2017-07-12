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
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PGTilingOverlayOption) {
    PGTilingOverlayOptionSingle,
    PGTilingOverlayOption2x2,
    PGTilingOverlayOption3x3
};

@interface PGTilingOverlay : NSObject

/**
 * Tile indices that are currently checked
 */
@property (strong, nonatomic, readonly) NSArray<NSNumber *> *selectedTiles;
@property (assign, nonatomic) BOOL isOverlayVisible;

- (void)addTilingOverlay:(PGTilingOverlayOption)tilingOption toView:(UIView *)view;
- (void)removeOverlay;

@end
