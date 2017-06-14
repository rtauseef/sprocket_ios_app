//
//  HPPRFacebookFilteredPhotoProvider.h
//  Pods
//
//  Created by Fernando Caprio on 6/13/17.
//
//

#import "HPPRFacebookPhotoProvider.h"


@protocol HPPRFacebookFilteredPhotoProviderDelegate <NSObject>

@required
- (NSDate *) fbFilterContentByDate;
- (CLLocation *) fbFilterContentByLocation;
- (int) fbDistanceForLocationFilter; // meters

@optional
- (void) fbRequestPhotoComplete:(int) count;

@end

@interface HPPRFacebookFilteredPhotoProvider : HPPRFacebookPhotoProvider

typedef enum HPPRFacebookFilteredPhotoProviderMode {
    HPPRFacebookFilteredPhotoProviderModeLocation,
    HPPRFacebookFilteredPhotoProviderModeDate,
    HPPRFacebookFilteredPhotoProviderUnknown
} HPPRFacebookFilteredPhotoProviderMode;

@property (weak, nonatomic) id<HPPRFacebookFilteredPhotoProviderDelegate> fbDelegate;

- (instancetype) initWithMode: (HPPRFacebookFilteredPhotoProviderMode) filteringMode;

@end
