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

#import "HPPRFacebookPhotoProvider.h"


@protocol HPPRFacebookFilteredPhotoProviderDelegate <NSObject>

@required

- (NSDate *)fbFilterContentByDate;
- (CLLocation *)fbFilterContentByLocation;
- (int)fbDistanceForLocationFilter; // meters

@optional

- (void)fbRequestPhotoComplete:(int)count;

@end

@interface HPPRFacebookFilteredPhotoProvider : HPPRFacebookPhotoProvider

typedef enum HPPRFacebookFilteredPhotoProviderMode {
    HPPRFacebookFilteredPhotoProviderModeLocation,
    HPPRFacebookFilteredPhotoProviderModeDate,
    HPPRFacebookFilteredPhotoProviderUnknown
} HPPRFacebookFilteredPhotoProviderMode;

@property (weak, nonatomic) id<HPPRFacebookFilteredPhotoProviderDelegate> fbDelegate;

- (instancetype)initWithMode:(HPPRFacebookFilteredPhotoProviderMode)filteringMode;

@end
