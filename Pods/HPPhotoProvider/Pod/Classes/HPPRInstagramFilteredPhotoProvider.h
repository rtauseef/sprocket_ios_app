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

#import <HPPRInstagramPhotoProvider.h>

@protocol HPPRInstagramFilteredPhotoProviderDelegate <NSObject>

@required

- (NSDate *)instagramFilterContentByDate;
- (int)instagramMaxSearchDepth;
- (CLLocation *)instagramFilterContentByLocation;
- (int)instagramDistanceForLocationFilter; // meters

@optional

- (void)instagramRequestPhotoComplete:(int)count;

@end

@interface HPPRInstagramFilteredPhotoProvider : HPPRInstagramPhotoProvider

typedef enum HPPRInstagramFilteredPhotoProviderMode {
    HPPRInstagramFilteredPhotoProviderModeLocation,
    HPPRInstagramFilteredPhotoProviderModeDate,
    HPPRInstagramFilteredPhotoProviderModeUnknown
} HPPRInstagramFilteredPhotoProviderMode;

@property (weak, nonatomic) id<HPPRInstagramFilteredPhotoProviderDelegate> instagramDelegate;

- (instancetype)initWithMode:(HPPRInstagramFilteredPhotoProviderMode)filteringMode;

@end
