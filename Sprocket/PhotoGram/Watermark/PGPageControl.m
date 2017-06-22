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

#import "PGPageControl.h"

#define kSpaceBetweenControls 6.0
#define kMinimumSizeForControl 200.0
#define kDefaultBarHeight 1.0
#define kSelectedBarHeight 3.0
#define kBarColor [UIColor lightGrayColor]


@interface PGPageControl ()
    @property (strong, nonatomic) NSMutableArray* pageViews;
@end

@implementation PGPageControl

// hack, re-visit this

- (void)addSubview:(UIView *)view {
    return;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    rect = self.bounds;
    
    if ( self.opaque ) {
        [self.backgroundColor set];
        UIRectFill( rect );
    }
    
    if ( self.hidesForSinglePage && self.numberOfPages == 1 ) return;
    
    float eachRectWidth = floorf((rect.size.width / self.numberOfPages) - ((self.numberOfPages - 1) * kSpaceBetweenControls / self.numberOfPages));
    
    if (eachRectWidth > kMinimumSizeForControl) {
        eachRectWidth = kMinimumSizeForControl;
    }
    
    CGRect drawRect;
    drawRect.size.width = eachRectWidth;
    drawRect.size.height = kDefaultBarHeight;
    
    drawRect.origin.x = floorf( ( rect.size.width - drawRect.size.width * self.numberOfPages - ((self.numberOfPages - 1) * kSpaceBetweenControls) ) / 2.0 );

    CGContextRef context = UIGraphicsGetCurrentContext();
    [kBarColor set];
    
    for (int i = 0; i < self.numberOfPages; i++) {
        // draw rect
        if (i == self.currentPage) {
            // draw selected
            drawRect.size.height = kSelectedBarHeight;
            drawRect.origin.y = floorf( ( rect.size.height - kSelectedBarHeight ) / 2.0 );

        } else {
            // draw unselected
            drawRect.size.height = kDefaultBarHeight;
            drawRect.origin.y = floorf( ( rect.size.height - kDefaultBarHeight ) / 2.0 );

        }
        
        CGContextFillRect(context, drawRect);
        
        drawRect.origin.x += drawRect.size.width + kSpaceBetweenControls;
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    [super setNumberOfPages:numberOfPages];
    [self setNeedsDisplay];
}

@end
