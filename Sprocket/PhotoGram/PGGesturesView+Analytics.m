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

#import "PGGesturesView+Analytics.h"
#import "PGAnalyticsManager.h"
#import <Crashlytics/Crashlytics.h>

@implementation PGGesturesView (Analytics)

- (void)rotate:(CGFloat)radians
{
    self.totalRotation += radians;
    
    self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, radians);
    float angle = atan2(self.scrollView.transform.b, self.scrollView.transform.a) * 180.0f / M_PI;
    
    NSString *angleValue = [NSString stringWithFormat:@"%.1f°", angle];

    [[Crashlytics sharedInstance] setObjectValue:angleValue forKey:@"Rotation"];
    if ([PGAnalyticsManager sharedManager].trackPhotoPosition) {
        [PGAnalyticsManager sharedManager].photoRotationEdited = YES;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self adjustContentOffset];
    
    [[Crashlytics sharedInstance] setObjectValue:[NSString stringWithFormat:@"%.1f", scale] forKey:@"Scale"];
    if ([PGAnalyticsManager sharedManager].trackPhotoPosition) {
        [PGAnalyticsManager sharedManager].photoZoomEdited = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[Crashlytics sharedInstance] setObjectValue:[NSString stringWithFormat:@"%.1f, %.1f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y] forKey:@"Offset"];
    if ([PGAnalyticsManager sharedManager].trackPhotoPosition) {
        [PGAnalyticsManager sharedManager].photoPanEdited = YES;
    }
}

@end
