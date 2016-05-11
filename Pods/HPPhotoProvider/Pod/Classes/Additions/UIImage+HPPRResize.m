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

#import "UIImage+HPPRResize.h"


@implementation UIImage (HPPRResize)

- (CGRect)HPPRRectForImageResize:(CGSize)resize
{
    CGFloat oldWidth = self.size.width;
    CGFloat scaleFactor = resize.width / oldWidth;
    
    CGFloat newHeight = self.size.height * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    
    return CGRectMake(0, 0, newWidth, newHeight);
}

- (UIImage *)HPPRImageResize:(CGSize)resize
{
    CGRect newRect = [self HPPRRectForImageResize:resize];
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, YES, 0.0);
    
    [self drawInRect:newRect];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
