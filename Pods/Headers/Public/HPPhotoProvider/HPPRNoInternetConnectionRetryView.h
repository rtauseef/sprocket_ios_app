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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPRView.h"

@protocol HPPRNoInternetConnectionRetryViewDelegate;

@interface HPPRNoInternetConnectionRetryView : HPPRView

@property (nonatomic, weak) id<HPPRNoInternetConnectionRetryViewDelegate> delegate;

@end


@protocol HPPRNoInternetConnectionRetryViewDelegate <NSObject>

- (void)noInternetConnectionRetryViewDidTapRetry:(HPPRNoInternetConnectionRetryView *)noInternetConnectionRetryView;

@end
