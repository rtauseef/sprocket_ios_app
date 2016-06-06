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

#import "UIView+Transform.h"

@implementation UIView (Transform)

- (CGFloat)transformScaleValueForContainerView:(UIView *)containerView
{
    CGFloat widthTransformScaleValue = containerView.frame.size.width / self.frame.size.width;
    CGFloat heightTransformScaleValue = containerView.frame.size.height / self.frame.size.height;
    
    return MIN(widthTransformScaleValue, heightTransformScaleValue);
}

- (void)centerInContainerView:(UIView *)containerView
{
    CGRect imageFrame = self.frame;
    imageFrame.origin.x = (containerView.frame.size.width / 2) - (imageFrame.size.width / 2);
    imageFrame.origin.y = (containerView.frame.size.height / 2) - (imageFrame.size.height / 2);
    self.frame = imageFrame;
}

@end
