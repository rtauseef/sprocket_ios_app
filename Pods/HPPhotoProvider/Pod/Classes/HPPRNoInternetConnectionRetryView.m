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

#import "HPPRNoInternetConnectionRetryView.h"
#import "UIFont+HPPRStyle.h"
#import "NSBundle+HPPRLocalizable.h"

@interface HPPRNoInternetConnectionRetryView()

@property (weak, nonatomic) IBOutlet UILabel *noInternetConnectionLabel;

@end

@implementation HPPRNoInternetConnectionRetryView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.noInternetConnectionLabel.font = [UIFont HPPRSimplifiedLightFontWithSize:12];
        self.noInternetConnectionLabel.text = HPPRLocalizedString(@"No Internet Connection", @"Message show to the user when there is no internet connection");
    }
    return self;
}

- (IBAction)retryButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(noInternetConnectionRetryViewDidTapRetry:)]) {
        [self.delegate noInternetConnectionRetryViewDidTapRetry:self];
    }
}

@end
