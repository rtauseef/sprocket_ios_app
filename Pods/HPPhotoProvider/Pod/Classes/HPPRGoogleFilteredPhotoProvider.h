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

#import <HPPRGooglePhotoProvider.h>

@protocol HPPRGoogleFilteredPhotoProviderDelegate <NSObject>

@required

- (NSDate *)googleFilterContentByDate;
- (int)googleMaxSearchDepth;
- (CLLocation *)googleFilterContentByLocation;
- (int)googleDistanceForLocationFilter; // meters

@optional

- (void)googleRequestPhotoComplete:(int)count;

@end

@interface HPPRGoogleFilteredPhotoProvider : HPPRGooglePhotoProvider

typedef enum HPPRGoogleFilteredPhotoProviderMode {
    HPPRGoogleFilteredPhotoProviderModeLocation,
    HPPRGoogleFilteredPhotoProviderModeDate,
    HPPRGoogleFilteredPhotoProviderModeUnknown
} HPPRGoogleFilteredPhotoProviderMode;

@property (weak, nonatomic) id<HPPRGoogleFilteredPhotoProviderDelegate> googleDelegate;

- (instancetype)initWithMode:(HPPRGoogleFilteredPhotoProviderMode)filteringMode;

@end
