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

#import "PGSocialSourcesCircleView.h"
#import "PGSocialSourcesManager.h"
#import "PGFeatureFlag.h"

@interface PGSocialSourcesCircleView ()

@property (nonatomic, strong) NSArray<PGSocialSource *> *socialSources;

@end

@implementation PGSocialSourcesCircleView

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self setupSocialSources];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingsChangedNotification:) name:kPGFeatureFlagPartyModeEnabledNotification object:nil];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];

    for (UIView *subview in self.subviews) {
        subview.userInteractionEnabled = userInteractionEnabled;
    }
}

#pragma mark - Private

- (void)handleSettingsChangedNotification:(NSNotification *)notification
{
    [[PGSocialSourcesManager sharedInstance] setupSocialSources];
    [self setupSocialSources];
}

- (void)setupSocialSources
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.socialSources = [[PGSocialSourcesManager sharedInstance] enabledSocialSources];

    CGFloat cameraCenterXY = self.frame.size.width / 2;

    UIImage *cameraImage = [UIImage imageNamed:@"cameraLanding"];
    CGFloat cameraRadius = cameraImage.size.width;

    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:cameraImage forState:UIControlStateNormal];
    cameraButton.frame = CGRectMake(cameraCenterXY - cameraRadius, cameraCenterXY - cameraRadius, cameraRadius * 2, cameraRadius * 2);
    [cameraButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraButton];

    CGFloat radius = cameraCenterXY - (self.socialSources[0].icon.size.width / 2);

    CGFloat numberOfCircles = self.socialSources.count;
    NSInteger extraIcons = 0;
    CGFloat stepDegrees = 360 / numberOfCircles;
    
    for (int i = 0; i < numberOfCircles; i++) {
        PGSocialSource *socialSource = self.socialSources[i];

        UIButton *socialButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [socialButton setImage:socialSource.icon forState:UIControlStateNormal];
        socialButton.frame = [self frameForImage:socialSource.icon step:stepDegrees center:cameraCenterXY radius:radius andIndex:(i + extraIcons)];
        socialButton.tag = i;

        [socialButton addTarget:self action:@selector(socialButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:socialButton];
    }

}

- (CGRect)frameForImage:(UIImage *)image step:(CGFloat)step center:(CGFloat)center radius:(CGFloat)radius andIndex:(NSInteger)index
{
    CGFloat deg = (step * index) + 90;
    CGFloat circleRadius = image.size.width;
    CGFloat yRadians = deg * M_PI / 180;
    CGFloat xRadians = (90 - deg) * M_PI / 180;
    CGFloat y = center - (radius * sinf(yRadians)) - circleRadius;
    CGFloat x = center - (radius * sinf(xRadians)) - circleRadius;
    return CGRectMake(x, y, circleRadius * 2, circleRadius * 2);
}

- (void)cameraButtonTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(socialCircleView:didTapOnCameraButton:)]) {
        [self.delegate socialCircleView:self didTapOnCameraButton:sender];
    }
}

- (void)socialButtonTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(socialCircleView:didTapOnSocialButton:withSocialSource:)]) {
        if (sender.tag >= 0 && sender.tag < self.socialSources.count) {
            PGSocialSource *socialSource = self.socialSources[sender.tag];
            [self.delegate socialCircleView:self didTapOnSocialButton:sender withSocialSource:socialSource];
        }
    }
}

@end
