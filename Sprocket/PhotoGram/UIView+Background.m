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

#import "UIView+Background.h"

@implementation UIView (Background)

- (CGSize)worstCaseViewSizeInInches
{
    // Scale info:
    // iPhone 6Plus: 3, iPhone 5 and 6: 2
    // IPad (including iPad Mini):2
    float scale = [[UIScreen mainScreen] scale];
    
    // ppi info:
    // iPhone6Plus: 401, iPhone 5 and 6: 326
    // iPad (non-mini): 264, iPad Mini: 326
    //
    // So, the ppi is going to be high for iPhone6Plus and non-mini iPads,
    //  but better safe than sorry for what we're doing... extra clear
    //  rather than blurry.
    float ppi = scale * 163;
    
    float width = (self.frame.size.width * scale);
    float height = (self.frame.size.height * scale);
    
    float horizontal = width / ppi;
    float vertical = height / ppi;
    
    // keep in mind that a transform is applied to the svgImageView which makes it
    // roughly twice as large as its actual size... thus the small size returned here.
    return CGSizeMake(horizontal, vertical);
}

// Our graphics context needs to be scaled such that it fits 5x7 photo paper without getting blurry...
//  Yes, scaling the 4x5 or 4x6 image for 5x7 will be overkill.  Just keeping things simple by going
//  straight to 5x7.
- (CGFloat)scaleFactorFor5x7
{
    CGSize viewSizeInInches = [self worstCaseViewSizeInInches];
    
    CGFloat scale = ( 5 > viewSizeInInches.width) ? 5 / viewSizeInInches.width : 1;
    
    // this makes it noticeably clearer
    scale += 1.0;

    return scale;
}

- (UIImage *)screenshotImage
{
    CGFloat originalScale = self.layer.contentsScale;
    CGFloat scale = [self scaleFactorFor5x7];
    
    // This is a hack... we had a mysterious 1 pixel grey border on our image
    //  Cutting off a pixel from the width and height fixes this.
    CGSize size = self.bounds.size;
    size.width -= 1;
    size.height -= 1;
    
    UIGraphicsBeginImageContextWithOptions(size, self.opaque, scale);
    
    self.layer.contentsScale = [UIScreen mainScreen].scale * scale;
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.layer.contentsScale = originalScale;
    
    return img;
}

@end
