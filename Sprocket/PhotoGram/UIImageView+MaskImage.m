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
#import "UIImageView+MaskImage.h"
#import "UIImage+ImageResize.h"

#define MASKED_IMAGE_SIZE 22.0f
#define MASKED_IMAGE_BORDER_WIDTH 1.0f

@implementation UIImageView (MaskImage)

- (void)setMaskImageWithURL:(NSString *)url
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        UIView *containerViewForScreenshot  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (MASKED_IMAGE_SIZE + MASKED_IMAGE_BORDER_WIDTH), (MASKED_IMAGE_SIZE + MASKED_IMAGE_BORDER_WIDTH))];
        containerViewForScreenshot.backgroundColor = [UIColor clearColor];
        
        UIImage *resizedImage = [image imageResize:CGSizeMake(MASKED_IMAGE_SIZE, MASKED_IMAGE_SIZE)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
        imageView.center = containerViewForScreenshot.center;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.layer.cornerRadius = MASKED_IMAGE_SIZE / 2;
        imageView.layer.masksToBounds = YES;
        
        [containerViewForScreenshot addSubview:imageView];
        
        // Add white border
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.lineWidth = MASKED_IMAGE_BORDER_WIDTH;
        circleLayer.fillColor = [[UIColor clearColor] CGColor];
        circleLayer.strokeColor = [[UIColor whiteColor] CGColor];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:containerViewForScreenshot.center
                        radius:(MASKED_IMAGE_SIZE / 2)
                    startAngle:0.0
                      endAngle:M_PI * 2.0
                     clockwise:YES];
        
        circleLayer.path = [path CGPath];
        
        circleLayer.shouldRasterize = YES;
        [containerViewForScreenshot.layer addSublayer:circleLayer];
        
        // This is taking a screenshot of the view to get an image to apply to the button.
        UIGraphicsBeginImageContextWithOptions(containerViewForScreenshot.frame.size, NO, 0);
        [containerViewForScreenshot.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *circleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self setImage:circleImage];
    });
}

@end
