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

#import "HPPRNoInternetConnectionMessageView.h"
#import "UIFont+HPPRStyle.h"
#import "NSBundle+HPPRLocalizable.h"

@interface HPPRNoInternetConnectionMessageView ()

@property (weak, nonatomic) IBOutlet UILabel *youAppearToBeOfflineLabel;
@property (assign, nonatomic) BOOL isAnimating;

@end

@implementation HPPRNoInternetConnectionMessageView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.youAppearToBeOfflineLabel.font = [UIFont HPPRSimplifiedLightFontWithSize:12];
        self.youAppearToBeOfflineLabel.text = HPPRLocalizedString(@"You appear to be offline", @"Message show to the user when there is no internet connection");
        self.alpha = 0.0f;
        self.isAnimating = NO;
    }
    return self;
}

- (void)show
{
    if (!self.isAnimating) {
        self.isAnimating = YES;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(hide) withObject:self afterDelay:3.0f];
        }];
    }
}

- (void)hide
{
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

@end
