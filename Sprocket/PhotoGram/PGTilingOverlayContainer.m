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

#import "PGTilingOverlayContainer.h"
#import "PGTilingOverlayTile.h"

@interface PGTilingOverlayContainer ()

@property (strong, nonatomic) IBOutletCollection(PGTilingOverlayTile) NSArray *tiles;

@end

@implementation PGTilingOverlayContainer

- (NSArray<NSNumber *> *)checkedTiles
{
    NSMutableArray<NSNumber *> *result = [NSMutableArray array];
    [self.tiles enumerateObjectsUsingBlock:^(PGTilingOverlayTile * _Nonnull tile, NSUInteger idx, BOOL * _Nonnull stop) {
        if (tile.isChecked) {
            [result addObject:tile.index];
        }
    }];
    return result;
}

@end
