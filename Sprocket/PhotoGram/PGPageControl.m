//
//  PGPageControl.m
//  Sprocket
//
//  Created by Fernando Caprio on 5/16/17.
//  Copyright © 2017 HP. All rights reserved.
//

#import "PGPageControl.h"

#define kSpaceBetweenControls 6.0
#define kMinimumSizeForControl 200.0
#define kDefaultBarHeight 3.0
#define kSelectedBarHeight 6.0
#define kBarColor [UIColor lightGrayColor]


@interface PGPageControl ()
    @property (strong, nonatomic) NSArray* pageViews;
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
    
    float eachRectWidth = (rect.size.width / self.numberOfPages) - ((self.numberOfPages - 1) * kSpaceBetweenControls / self.numberOfPages);
    
    if (eachRectWidth > kMinimumSizeForControl) {
        eachRectWidth = kMinimumSizeForControl;
    }
    
    CGRect drawRect;
    drawRect.size.width = eachRectWidth;
    drawRect.size.height = kDefaultBarHeight;
    
    drawRect.origin.x = floorf( ( rect.size.width - drawRect.size.width * self.numberOfPages - ((self.numberOfPages - 1) * kSpaceBetweenControls) ) / 2.0 );
    
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

        CGContextRef context = UIGraphicsGetCurrentContext();
        [kBarColor set];
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
