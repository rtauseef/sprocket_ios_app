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

#import "UIImage+HPPRMaskImage.h"
#import "UIImage+HPPRResize.h"

@implementation UIImage (HPPRMaskImage)

+ (void)HPPRMaskImageWithURL:(NSString *)url diameter:(float)diameter borderWidth:(float)borderWidth completion:(void (^)(UIImage *))completion
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        UIView *containerViewForScreenshot  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (diameter + borderWidth), (diameter + borderWidth))];
        containerViewForScreenshot.backgroundColor = [UIColor clearColor];
        
        UIImage *resizedImage = [image HPPRImageResize:CGSizeMake(diameter, diameter)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
        imageView.center = containerViewForScreenshot.center;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.layer.cornerRadius = diameter / 2;
        imageView.layer.masksToBounds = YES;
        
        [containerViewForScreenshot addSubview:imageView];
        
        // Add white border
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.lineWidth = borderWidth;
        circleLayer.fillColor = [[UIColor clearColor] CGColor];
        circleLayer.strokeColor = [[UIColor whiteColor] CGColor];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:containerViewForScreenshot.center
                        radius:(diameter / 2)
                    startAngle:0.0
                      endAngle:M_PI * 2.0
                     clockwise:YES];
        
        circleLayer.path = [path CGPath];
        
        circleLayer.shouldRasterize = YES;
        [containerViewForScreenshot.layer addSublayer:circleLayer];
        
        // This is taking a screenshot of the view to get an image to apply to the button.
        UIGraphicsBeginImageContextWithOptions(containerViewForScreenshot.frame.size, NO, 0);
        [containerViewForScreenshot.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *circleImage = circleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (completion) {
            completion(circleImage);
        }
    });
}

@end
