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

#import "PGTilingOverlay.h"

@interface PGTilingOverlay ()

@property (strong, nonatomic) UIView *currentTiling;

@end

@implementation PGTilingOverlay

- (void)showTilingOverlay:(PGTilingOverlayOption)tilingOption
{
    if (self.currentTiling) {
        [self.currentTiling removeFromSuperview];
        self.currentTiling = nil;
    }
    
    if (tilingOption == PGTilingOverlayOptionSingle) {
        return;
    }
    
    NSString *nibName = [NSString stringWithFormat:@"%@%@", NSStringFromClass(self.class), [self tilingOptionString:tilingOption]];
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    self.currentTiling = subviewArray.firstObject;
    if (self.currentTiling) {
        [self addSubview:self.currentTiling];
        self.currentTiling.frame = self.bounds;
    }
}

- (NSString *)tilingOptionString:(PGTilingOverlayOption)tilingOption
{
    NSArray<NSString *> *tilingOptionArray = @[@"2x2", @"3x3"];
    return [tilingOptionArray objectAtIndex:tilingOption-1];
}

@end
