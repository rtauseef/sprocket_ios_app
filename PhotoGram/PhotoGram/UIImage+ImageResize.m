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

#import "UIImage+ImageResize.h"


@implementation UIImage (ImageResize)

- (CGRect)rectForImageResize:(CGSize)resize
{
    CGFloat oldWidth = self.size.width;
    CGFloat scaleFactor = resize.width / oldWidth;
    
    CGFloat newHeight = self.size.height * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;

	return CGRectMake(0, 0, newWidth, newHeight);
}

- (UIImage *)imageResize:(CGSize)resize
{
    CGRect newRect = [self rectForImageResize:resize];

    // performing a drawRect without scaling the graphics context results in blurry prints
    CGFloat xScale = self.size.width / newRect.size.width;
    CGFloat yScale = self.size.height / newRect.size.height;
    CGFloat scale = fmaxf(xScale, yScale);
    scale += 1.0; // noticable improvement in clarity

    UIGraphicsBeginImageContextWithOptions(newRect.size, YES, scale);

    [self drawInRect:newRect];

    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return scaledImage;
}

- (CGSize)imageFinalSizeAfterContentModeApplied:(UIViewContentMode)contentMode containerSize:(CGSize)containerSize
{
    CGFloat scaleX = containerSize.width / self.size.width;
    CGFloat scaleY = containerSize.height / self.size.height;
    CGFloat scale = 1.0;
    
    CGSize finalSizeScale;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFit:
            scale = fminf(scaleX, scaleY);
            finalSizeScale = CGSizeMake(scale, scale);
            break;
            
        case UIViewContentModeScaleAspectFill:
            scale = fmaxf(scaleX, scaleY);
            finalSizeScale = CGSizeMake(scale, scale);
            break;
            
        case UIViewContentModeScaleToFill:
            finalSizeScale = CGSizeMake(scaleX, scaleY);
            break;
            
        default:
            finalSizeScale = CGSizeMake(scale, scale);
            break;
    }
    
    return CGSizeMake(finalSizeScale.width * self.size.width, finalSizeScale.height * self.size.height);
}

@end
